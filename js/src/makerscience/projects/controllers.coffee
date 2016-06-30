module = angular.module("makerscience.projects.controllers", ["commons.accounts.controllers", 'makerscience.base.services', 'commons.tags.services',
            'makerscience.base.controllers'])

# module.controller("ProjectListCtrl", ($scope, Project) ->
#     $scope.projects = Project.getList().$object
# )


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

module.controller("MakerScienceProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $filter, $window, $modal, ProjectService, TaggedItemService,
                                                    MakerScienceProject, MakerScienceProjectLight, MakerScienceResource,  MakerSciencePostLight,
                                                    MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress, ProjectNews
                                                    Comment, ObjectProfileLink, DataSharing) ->

    $controller('VoteCtrl', {$scope: $scope})
    $controller('PostCtrl', {$scope: $scope})

    $scope.openTagPopup = (preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) ->
      TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback)

    $scope.preparedThemeTags = []
    $scope.preparedFormatsTags = []
    $scope.preparedTargetTags = []
    $scope.editable = false
    $scope.objectId = null
    $scope.medias = []

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]
        $scope.editable = $scope.projectsheet.can_edit
        $scope.objectId = $scope.projectsheet.id
        console.log $scope.projectsheet
        $scope.openGallery = (projectsheet) ->
            modalInstance = $modal.open(
                templateUrl: '/views/gallery/gallery-project-modal.html'
                controller: 'GalleryEditionInstanceCtrl'
                size: 'lg'
                backdrop : 'static'
                keyboard : false
                resolve:
                    projectsheet: ->
                        return projectsheet
                    medias: ->
                        return $scope.medias
            )
            modalInstance.result.then((result)->
                $scope.$emit('cover-updated')
                $scope.medias = []
            )

        $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
            resources = {
              resourceName: resourceName
              resourceId: resourceId
              fieldName: fieldName
              data: data
            }
            ProjectService.updateProjectSheet(resources, $scope.projectsheet)

        ProjectService.fetchCoverURL($scope.projectsheet.base_projectsheet)

        $scope.$on('cover-updated', ()->
            ProjectService.fetchCoverURL($scope.projectsheet.base_projectsheet)
            MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
                $scope.projectsheet = makerScienceProjectResult.objects[0]
            )
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
