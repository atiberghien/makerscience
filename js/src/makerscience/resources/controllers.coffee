module = angular.module("makerscience.resources.controllers", ["commons.accounts.controllers", 'makerscience.base.services', 'commons.tags.services',
            'makerscience.base.controllers'])

module.controller("MakerScienceResourceListCtrl", ($scope, $controller, StaticContent, MakerScienceResourceLight, MakerScienceResourceTaggedItem, FilterService) ->
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
        $scope.resources = []
        $scope.waitingList = true

    $scope.refreshList = ()->
        return MakerScienceResourceLight.one().customGETLIST('search', $scope.params).then((makerScienceResourceResults) ->
            meta = makerScienceResourceResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.resources =  makerScienceResourceResults
            $scope.waitingList = false
        )

    # Must be called AFTER refreshList definition due to inheriance
    $scope.initMakerScienceAbstractListCtrl()

    $scope.fetchRecentResources = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-created_on'
        $scope.refreshList()

    $scope.fetchTopResources = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-total_score'
        $scope.refreshList()

    $scope.fetchRandomResources = () ->
        $scope.$broadcast('clearFacetFilter')
        delete $scope.params['ordering']
        $scope.refreshList().then(->
            nbElmt = $scope.resources.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.resources[nbElmt]
                $scope.resources[nbElmt] = $scope.resources[rand]
                $scope.resources[rand] = tmp
        )

    $scope.fetchThematicResources = () ->
        $scope.clearList()
        $scope.params['ordering'] = '-created_on'
        FilterService.filterParams.tags = $scope.selected_themes_facets
        # $scope.refreshList()

    $scope.fetchRecentResources()

    $scope.availableThemeTags = []
    $scope.availableFormatsTags = []
    $scope.availableTargetTags = []

    MakerScienceResourceTaggedItem.getList({distinct : 'True'}).then((taggedItemResults) ->
        angular.forEach(taggedItemResults, (taggedItem) ->
            switch taggedItem.tag_type
                when 'th' then $scope.availableThemeTags.push(taggedItem.tag)
                when 'fm' then $scope.availableFormatsTags.push(taggedItem.tag)
                when 'tg' then $scope.availableTargetTags.push(taggedItem.tag)
        )
    )
)

module.controller("MakerScienceResourceSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $modal, $filter, ProjectService, TaggedItemService,
                                                    MakerScienceResource, MakerScienceResourceLight, MakerScienceResourceTaggedItem, MakerSciencePostLight, TaggedItem,
                                                    Comment, ObjectProfileLink, DataSharing) ->

    $controller('VoteCtrl', {$scope: $scope})

    $scope.openTagPopup = (preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) ->
      TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback)

    $scope.preparedThemeTags = []
    $scope.preparedFormatsTags = []
    $scope.preparedTargetTags = []

    $scope.editable = false
    $scope.objectId = null
    $scope.medias = []

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0]
        $scope.objectId = $scope.projectsheet.id
        $scope.editable = $scope.projectsheet.can_edit

        console.log $scope.projectsheet
        $scope.getFilterMedias = () ->
            $scope.mediasToShow = $filter('filter')($scope.projectsheet.base_projectsheet.bucket.files, {type: '!cover'})
            $scope.filteredByAuthor = $filter('filter')($scope.mediasToShow, {is_author: true, type: '!experience'})
            $scope.filteredByNotAuthor = $filter('filter')($scope.mediasToShow, {is_author: false, type: '!experience'})
            $scope.filteredByExperience = $filter('filter')($scope.mediasToShow, {type: 'experience'})

        $scope.getFilterMedias()

        $scope.openGallery = (projectsheet) ->
            modalInstance = $modal.open(
                templateUrl: '/views/gallery/gallery-resource-modal.html'
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

        $scope.openCover = (projectsheet) ->
            modalInstance = $modal.open(
                templateUrl: '/views/modal/cover-modal.html'
                controller: 'CoverResourceSheetCtrl'
                size: 'lg'
                backdrop : 'static'
                keyboard : false
                resolve:
                    base_projectsheet: ->
                        return $scope.projectsheet.base_projectsheet
            )
            modalInstance.result.then((result)->
                $scope.projectsheet.base_projectsheet.cover = result
                coverId = if $scope.projectsheet.base_projectsheet.cover then $scope.projectsheet.base_projectsheet.cover.id else null
                $scope.coverURL = ProjectService.fetchCoverURL(coverId)
            )

        $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
            resources = {
              resourceName: resourceName
              resourceId: resourceId
              fieldName: fieldName
              data: data
            }
            ProjectService.updateProjectSheet(resources, $scope.projectsheet)

        coverId = if $scope.projectsheet.base_projectsheet.cover then $scope.projectsheet.base_projectsheet.cover.id else null
        $scope.coverURL = ProjectService.fetchCoverURL(coverId)

        $scope.$on('cover-updated', ()->
            MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
                $scope.projectsheet = makerScienceResourceResult.objects[0]
                $scope.getFilterMedias()
            )
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceresource'
                    $scope.similars.push(MakerScienceResourceLight.one(similar.id).get().$object)
            )
        )

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "th" then $scope.preparedThemeTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug, taggedItemId : taggedItem.id})
                when "tg" then $scope.preparedTargetTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
                when "fm" then $scope.preparedFormatsTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
        )

        if _.isEmpty($scope.resourcesheet.base_projectsheet.videos)
            $scope.resourcesheet.base_projectsheet.videos = null

        $scope.updateLinkedResources = ->
            MakerScienceResource.one($scope.projectsheet.id).patch(
                linked_resources : $scope.linkedResources.map((resource) ->
                    return resource.resource_uri
                )
            )

        ## ONLY DEFINE AND/OR CALL THESE METHODS IF AND ONLY IF $scope.currentMakerScienceProfile IS AVAILABLE
        $scope.$watch('currentMakerScienceProfile', (newValue, oldValue) ->
            if newValue != null && newValue != undefined

                $scope.addTagToResourceSheet = (tag_type, tag) ->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+$scope.projectsheet.id+"/"+tag_type, {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                        tag.taggedItemId = taggedItemResult.id
                    )

                $scope.removeTagFromResourceSheet = (tag) ->
                  MakerScienceResourceTaggedItem.one(tag.taggedItemId).remove()

                $scope.saveMakerScienceResourceVote = (voteType, score) ->
                    # profileID, objectTypeName, objectID, voteType, score, objectProfileLinkType
                    $scope.saveVote($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id, voteType, score, 14)

                $scope.loadVotes($scope.currentMakerScienceProfile.parent.id, 'makerscienceresource', $scope.resourcesheet.id)
            else
                $scope.loadVotes(null, 'makerscienceresource', $scope.resourcesheet.id)
        )
    )

    $scope.updateMakerScienceResourceSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceResource' then MakerScienceResource.one(resourceId).patch(putData)
)

module.controller("CoverResourceSheetCtrl", ($scope, $modalInstance, ProjectService, ProjectSheet, base_projectsheet, GalleryService) ->
        $scope.resourceCover = {type: 'cover'}
        $scope.ok = () ->
            $scope.hideControls = true

            if $scope.resourceCover.file
                ProjectService.uploadMedia($scope.resourceCover, base_projectsheet.bucket.id, base_projectsheet.id).then((res) ->
                    $scope.hideControls = false
                    ProjectSheet.one(base_projectsheet.id).patch({cover: res.resource_uri})
                    $modalInstance.close(res)
                  )
            else
                $modalInstance.close(null)

        $scope.close = ->
            $modalInstance.dismiss('cancel')

        $scope.change = () ->
            scope.$apply ->
                scope.coverForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type))

)
