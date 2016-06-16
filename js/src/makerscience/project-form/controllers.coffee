module = angular.module("makerscience.projects.controllers")

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, $filter, $timeout, @$http, FileUploader, ProjectService
                                                        ProjectProgress, ProjectSheet, FormService, ProjectSheetQuestionAnswer, Project,
                                                        MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerScienceProjectTaggedItem,
                                                        ObjectProfileLink) ->


    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))
    $scope.projectsheet = { medias: {} }
    $scope.QAItems = []

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
    $scope.coverIndex = null

    $scope.uploader = uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )

    #TODO : externalise 'projet-makerscience' info in static config table
    ## initialize projectsheet, QAItems, projectsheet.template in scope
    # $scope.initProjectSheetCreateCtrl('projet-makerscience')

    #TODO : externalise 'makerscience' info in static config table
    ProjectProgress.getList({'range__slug' : 'makerscience'}).then((progressRangeResult) ->
        $scope.progressRange = [{ value : progress.resource_uri, text : progress.label } for progress in $filter('orderBy')(progressRangeResult, 'order')][0]
    )

    $scope.addNeed = (need) ->
        $scope.needs.push(angular.copy($scope.newNeed))
        $scope.newNeed = {}

    $scope.delNeed = (index) ->
        $scope.needs.splice(index, 1)

    $scope.saveMakerscienceProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            $scope.hideControls = false
            return false
        else
            console.log("submitting form")

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

                ProjectSheet.one(projectsheetResult.id).patch({medias:$scope.projectsheet.medias})
                # if no photos to upload, directly go to new project sheet

                # must use tmp var in order to not modify queue during cover candidate saving ... sync issue
                if $scope.uploader.queue.length == 0
                    $scope.fake_progress = 0
                    ##UGLY : to be sur that all remote ops are finished ... :/
                    for x in [1..5]
                        $scope.fake_progress += 100/5

                    $timeout(() ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})
                    ,5000)
                else
                    $scope.uploader.onBeforeUploadItem = (item) ->
                        item.formData.push(
                            bucket : projectsheetResult.bucket.id
                        )
                        item.headers =
                           Authorization : $scope.uploader.headers["Authorization"]

                    $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
                        fileIndex = $scope.uploader.getIndexOfItem(fileItem)

                        angular.forEach($scope.projectsheet.medias, (media, key) ->
                            if media.bucket && Number(key) == fileIndex + 1
                                media.file = fileItem.file
                                console.log
                          )
                        console.log $scope.projectsheet.medias
                        ProjectSheet.one(projectsheetResult.id).patch({medias: $scope.projectsheet.medias})

                        if fileIndex == $scope.coverIndex
                            ProjectSheet.one(projectsheetResult.id).patch({cover:response.resource_uri})

                    $scope.uploader.onCompleteAll = () ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})

                    $scope.uploader.uploadAll()
            )
        )
)
