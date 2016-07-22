module = angular.module("makerscience.projects.controllers")

module.controller("MakerScienceProjectSheetCreateCtrl", ($window, $scope, $state, $controller, $modal, $filter, $timeout, ProjectService, GalleryService,
                                                        ProjectProgress, ProjectSheet, FormService, ProjectSheetQuestionAnswer, Project,
                                                        MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerScienceProjectTaggedItem,
                                                        ObjectProfileLink) ->


    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))
    $scope.projectsheet = { medias: [] }
    $scope.QAItems = []
    $scope.status2 = {}
    $scope.status2.open = false;

    FormService.init('projet-makerscience-2016').then((response) ->
        $scope.QAItems = response.QAItems
        $scope.projectsheet = response.projectsheet
    )

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.needs = []
    $scope.newNeed = {}

    $scope.hideControls = false
    $scope.medias = []

    #TODO : externalise 'projet-makerscience' info in static config table
    ## initialize projectsheet, QAItems, projectsheet.template in scope
    # $scope.initProjectSheetCreateCtrl('projet-makerscience')

    #TODO : externalise 'makerscience' info in static config table
    ProjectProgress.getList({'range__slug' : 'makerscience'}).then((progressRangeResult) ->
        $scope.progressRange = [{ value : progress.resource_uri, text : progress.label } for progress in $filter('orderBy')(progressRangeResult, 'order')][0]
    )

    $scope.openInfosLink = (projectsheet, QAItems) ->
        modalInstance = $modal.open(
            templateUrl: '/views/modal/infolink-modal.html'
            controller: 'InfoLinkCtrl'
            size: 'lg'
            backdrop : 'static'
            keyboard : false
        )
        modalInstance.result.then((result)->
            if !$scope.projectsheet.project
                $scope.projectsheet.project = {}
            $scope.projectsheet.project.title = result.title
            $scope.projectsheet.project.website = result.url
            $scope.status2.open = true;
            $scope.QAItems[0].answer = result.description
            $window.tinymce.editors[0].setContent(result.description)
        )

    $scope.addNeed = (need) ->
        $scope.needs.push(angular.copy($scope.newNeed))
        $scope.newNeed = {}

    $scope.delNeed = (index) ->
        $scope.needs.splice(index, 1)

    $scope.saveMakerscienceProject = (form) ->
        requiredFields = [
          'projectName'
          'projectBaseline'
          'localisation'
        ]

        for field in requiredFields
            if form[field].$error.required
                $scope.hideControls = false
                return false

        FormService.save($scope.projectsheet).then((projectsheetResult) ->
            angular.forEach($scope.QAItems, (q_a) ->
                q_a.projectsheet = projectsheetResult.resource_uri
                ProjectSheetQuestionAnswer.post(q_a)
            )

            makerscienceProjectData =
                parent : projectsheetResult.project.resource_uri

            MakerScienceProject.post(makerscienceProjectData).then((makerscienceProjectResult)->
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 0,
                    detail : "Créateur/Créatrice",
                    isValidated:true
                , 'makerscienceproject/'+makerscienceProjectResult.id)

                angular.forEach($scope.themesTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/th", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.formatsTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/fm", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.targetsTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/tg", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                MakerScienceProjectLight.one(makerscienceProjectResult.id).get().then((projectResult) ->
                    angular.forEach($scope.needs, (needPost) ->
                        needPost.linked_projects = [projectResult.resource_uri]
                        needPost.type='need'
                        $scope.saveMakersciencePost(needPost, null, $scope.currentMakerScienceProfile.parent)
                    )
                )

                # if no photos to upload, directly go to new project sheet
                if _.size($scope.medias) == 0
                    $scope.fake_progress = 0
                    ##UGLY : to be sur that all remote ops are finished ... :/
                    for x in [1..5]
                        $scope.fake_progress += 100/5

                    $timeout(() ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})
                    ,5000)
                else
                    $scope.coverId = GalleryService.coverId

                    promises = []

                    angular.forEach($scope.medias, (media, index) ->
                        promise = ProjectService.uploadMedia(media, projectsheetResult.bucket.id, projectsheetResult.id)
                        promises.push(promise)

                        promise.then((res) ->
                            if $scope.coverId == media.id
                                ProjectSheet.one(projectsheetResult.id).patch({cover: res.resource_uri})
                          )
                    )

                    Promise.all(promises).then(() ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})
                    ).catch((err) ->
                        console.error err
                    )
            )
        )
)

module.controller("InfoLinkCtrl", ($scope, $modalInstance, MediaRestangular) ->

    $scope.close = ->
        $modalInstance.dismiss('close')

    $scope.ok = (link) ->
        if ($scope.infoLinkForm.$invalid)
            return false

        MediaRestangular.one('geturl').get({'url': link.$modelValue})
          .then((res) ->
              $modalInstance.close(res)
          )
          .catch((err) ->
              console.error err
          )

)
