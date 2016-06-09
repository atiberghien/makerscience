module = angular.module("makerscience.catalog.controllers.project", ['makerscience.catalog.services', "makerscience.catalog.controllers.generic",
            'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services',
            'makerscience.base.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, $controller, MakerScienceProjectLight, StaticContent, FilterService, MakerScienceProjectTaggedItem) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.params["limit"] = $scope.limit =  6

    $scope.selected_themes = []
    $scope.selected_themes_facets = ""
    StaticContent.one(1).get().then((staticResult) ->
        angular.forEach(staticResult.project_thematic_selection, (tag) ->
            if $scope.selected_themes_facets != ""
                $scope.selected_themes_facets += ","
            $scope.selected_themes_facets += tag.slug
            $scope.selected_themes.push(tag)
        )
    )

    $scope.clearList = () ->
        $scope.$broadcast('clearFacetFilter')
        $scope.projects = []
        $scope.waitingList = true

    $scope.refreshList = ()->
        return MakerScienceProjectLight.one().customGETLIST('search', $scope.params).then((makerScienceProjectResults) ->
            meta = makerScienceProjectResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.projects =  makerScienceProjectResults
            $scope.waitingList = false
        )

    # Must be called AFTER refreshList definition due to inheriance
    $scope.initMakerScienceAbstractListCtrl()

    $scope.fetchRecentProjects = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-created_on'
        $scope.refreshList()

    $scope.fetchTopProjects = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-total_score'
        $scope.refreshList()

    $scope.fetchRandomProjects = () ->
        $scope.clearList()
        delete $scope.params['ordering']
        $scope.refreshList().then(->
            nbElmt = $scope.projects.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.projects[nbElmt]
                $scope.projects[nbElmt] = $scope.projects[rand]
                $scope.projects[rand] = tmp
        )

    $scope.fetchThematicProjects = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-created_on'
        FilterService.filterParams.tags = $scope.selected_themes_facets
        # $scope.refreshList()

    $scope.fetchRecentProjects()

    $scope.availableThemeTags = []
    $scope.availableFormatsTags = []
    $scope.availableTargetTags = []

    MakerScienceProjectTaggedItem.getList({distinct : 'True'}).then((taggedItemResults) ->
        angular.forEach(taggedItemResults, (taggedItem) ->
            switch taggedItem.tag_type
                when 'th' then $scope.availableThemeTags.push(taggedItem.tag)
                when 'fm' then $scope.availableFormatsTags.push(taggedItem.tag)
                when 'tg' then $scope.availableTargetTags.push(taggedItem.tag)
        )
    )
)

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, $filter, $timeout, @$http, FileUploader,
                                                        ProjectProgress, ProjectSheet, ProjectService, ProjectSheetQuestionAnswer,
                                                        MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerScienceProjectTaggedItem,
                                                        ObjectProfileLink) ->

    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.needs = []
    $scope.newNeed = {}

    $scope.hideControls = false

    $scope.projectsheet =
        videos : {}
    $scope.QAItems = []

    ProjectService.init('projet-makerscience').then((response) ->
        $scope.QAItems = response.QAItems
        $scope.projectsheet = response.projectsheet
    )

    $scope.uploader = new FileUploader(
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

        ProjectService.save($scope.projectsheet).then((projectsheetResult) ->
            angular.forEach($scope.QAItems, (q_a) ->
                q_a.projectsheet = projectsheetResult.resource_uri
                ProjectSheetQuestionAnswer.post(q_a)
            )
            makerscienceProjectData =
                parent : projectsheetResult.project.resource_uri
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

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

                ProjectSheet.one(projectsheetResult.id).patch({videos:$scope.projectsheet.videos})
                # if no photos to upload, directly go to new project sheet
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
                        if $scope.uploader.getIndexOfItem(fileItem) == $scope.coverIndex
                            ProjectSheet.one(projectsheetResult.id).patch({cover:response.resource_uri})

                    $scope.uploader.onCompleteAll = () ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})

                    $scope.uploader.uploadAll()
            )
        )
)

module.controller("NewNeedPopupInstanceCtrl",  ($scope, $controller, $modalInstance, projectsheet, MakerScienceProjectLight, MakerSciencePostLight) ->

    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))
    $scope.newNeed = {
        title : '',
        text : '',
        type : 'need'
    }


    $scope.ok = () ->
        $scope.errors = []
        if $scope.newNeed.title == ""
            $scope.errors.push("title")
        if String($scope.newNeed.text).replace(/<[^>]+>/gm, '') == ""
            $scope.errors.push("text")

        if $scope.errors.length == 0
            MakerScienceProjectLight.one(projectsheet.id).get().then((projectResult) ->
                $scope.newNeed.linked_projects = [projectResult.resource_uri]
                $scope.saveMakersciencePost($scope.newNeed, null, $scope.currentMakerScienceProfile.parent).then((postResult)->
                    MakerSciencePostLight.one(postResult.id).get().then((post)->
                        post.author = $scope.currentMakerScienceProfile.parent
                        projectsheet.linked_makersciencepost.push(post)
                    )
                )
            )
            $modalInstance.close()

    $scope.cancel = () ->
        $modalInstance.dismiss('cancel')
)

module.controller("MakerScienceProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $filter,$window, $modal
                                                    MakerScienceProject, MakerScienceProjectLight, MakerScienceResource,  MakerSciencePostLight,
                                                    MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress, ProjectNews
                                                    Comment, ObjectProfileLink, DataSharing) ->

    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})
    $controller('VoteCtrl', {$scope: $scope})
    $controller('PostCtrl', {$scope: $scope})

    angular.extend(this, $controller('CommunityCtrl', {$scope: $scope}))
    angular.extend(this, $controller('CommentCtrl', {$scope: $scope}))

    $scope.preparedThemeTags = []
    $scope.preparedFormatsTags = []
    $scope.preparedTargetTags = []

    $scope.editable = false

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]

        $scope.editable = $scope.projectsheet.can_edit

        $scope.initCommunityCtrl("makerscienceproject", $scope.projectsheet.id)
        $scope.initCommentCtrl("makerscienceproject", $scope.projectsheet.id)

        $scope.linkedResources = $scope.projectsheet.linked_resources

        $scope.fetchCoverURL($scope.projectsheet.base_projectsheet)
        $scope.$on('cover-updated', ()->
            $scope.fetchCoverURL($scope.projectsheet.base_projectsheet)
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceproject'
                    $scope.similars.push(MakerScienceProjectLight.one(similar.id).get().$object)
            )
        )

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "th" then $scope.preparedThemeTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug, taggedItemId : taggedItem.id})
                when "tg" then $scope.preparedTargetTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
                when "fm" then $scope.preparedFormatsTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
        )

        if _.isEmpty($scope.projectsheet.base_projectsheet.videos)
            $scope.projectsheet.base_projectsheet.videos = null

        angular.forEach($scope.projectsheet.linked_makersciencepost, (makerSciencePostResult) ->
            $scope.getPostAuthor(makerSciencePostResult.parent_id).then((author) ->
                makerSciencePostResult.author = author
            )
            $scope.getContributors(makerSciencePostResult.parent_id).then((contributors) ->
                makerSciencePostResult.contributors = contributors
            )
        )

        $scope.newsData = {}
        $scope.publishNews = () ->
            newsText = String($scope.newsData.text).replace(/<[^>]+>/gm, '')
            if $scope.newsData.title == '' || $scope.newsData.title == undefined || newsText == '' || newsText == 'undefined'
                return false

            $scope.newsData.author = $scope.currentMakerScienceProfile.parent.id
            $scope.newsData.project = $scope.projectsheet.parent.id
            MakerScienceProject.one().customPOST($scope.newsData, 'publish/news').then((newsResult)->
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 7,
                    detail : '',
                    isValidated:true
                , 'projectnews/'+newsResult.id)
                $scope.projectsheet.news.unshift(newsResult)
                angular.copy({}, $scope.newsData);
                $window.tinymce.activeEditor.setContent('')
            )

        $scope.openNewNeedPopup = () ->
            modalInstance = $modal.open(
                templateUrl: '/views/block/newNeedPopup.html'
                controller: 'NewNeedPopupInstanceCtrl'
                resolve:
                    projectsheet: ->
                        return $scope.projectsheet
            )

        $scope.deleteNews = (news) ->
            ProjectNews.one(news.id).remove().then(->
                $scope.projectsheet.news.splice($scope.projectsheet.news.indexOf(news), 1)
            )

        $scope.updateNews = (news) ->
            ProjectNews.one(news.id).patch({text: news.text}).then(->
                $scope.projectsheet.news[$scope.projectsheet.news.indexOf(news)].text = news.text
            )

        $scope.updateLinkedResources = ->
            MakerScienceProject.one($scope.projectsheet.id).patch(
                linked_resources : $scope.linkedResources.map((resource) ->
                    return resource.resource_uri
                )
            )

        ProjectProgress.getList({'range__slug' : 'makerscience'}).then((progressRangeResult) ->
            $scope.progressRange = [{ value : progress.resource_uri, text : progress.label } for progress in $filter('orderBy')(progressRangeResult, 'order')][0]

            $scope.showProjectProgress = () ->
                selected = $filter('filter')($scope.progressRange, {value: $scope.projectsheet.parent.progress.resource_uri});
                return if $scope.projectsheet.parent.progress.label && selected.length then selected[0].text else 'non renseigné'
        )

        ## ONLY DEFINE AND/OR CALL THESE METHODS IF AND ONLY IF $scope.currentMakerScienceProfile IS AVAILABLE
        $scope.$watch('currentMakerScienceProfile', (newValue, oldValue) ->
            if newValue != null && newValue != undefined
                $scope.addTagToProjectSheet = (tag_type, tag) ->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+$scope.projectsheet.id+"/"+tag_type, {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                        tag.taggedItemId = taggedItemResult.id
                    )

                $scope.removeTagFromProjectSheet = (tag) ->
                  MakerScienceProjectTaggedItem.one(tag.taggedItemId).remove()

                $scope.saveMakerScienceProjectVote = (voteType, score) ->
                    # profileID, objectTypeName, objectID, voteType, score, objectProfileLinkType
                    $scope.saveVote($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id, voteType, score, 4)

                $scope.loadVotes($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id)
            else
                $scope.loadVotes(null, 'makerscienceproject', $scope.projectsheet.id)
        )
    )

    $scope.updateMakerScienceProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceProject' then MakerScienceProject.one(resourceId).patch(putData)
)
