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

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, $timeout, ProjectSheet, FormService,
                             MakerScienceResource,  MakerScienceResourceTaggedItem, ObjectProfileLink) ->

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.hideControls = false

    $scope.projectsheet =
        videos : {}
    $scope.QAItems = []

    FormService.init('experience-makerscience').then((response) ->
        $scope.QAItems = response.QAItems
        $scope.projectsheet = response.projectsheet
    )

    $scope.saveMakerscienceResource = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            $scope.hideControls = false
            return false
        else
            console.log("submitting form")

        FormService.save().then((resourcesheetResult) ->
            makerscienceResourceData =
                parent : resourcesheetResult.project.resource_uri
                duration : $scope.projectsheet.duration

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 10,
                    detail : "Créateur/Créatrice",
                    isValidated:true
                , 'makerscienceresource/'+makerscienceResourceResult.id)

                angular.forEach($scope.themesTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/th", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.formatsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/fm", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.targetsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/tg", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )


                ProjectSheet.one(resourcesheetResult.id).patch({videos:$scope.projectsheet.videos})
                # if no photos to upload, directly go to new project sheet
                if $scope.uploader.queue.length == 0
                    $scope.fake_progress = 0
                    ##UGLY : to be sur that all remote ops are finished ... :/
                    for x in [1..5]
                        $scope.fake_progress += 100/5

                    $timeout(() ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
                    ,5000)
                else
                    $scope.uploader.onBeforeUploadItem = (item) ->
                        item.formData.push(
                            bucket : resourcesheetResult.bucket.id
                        )
                        item.headers =
                           Authorization : $scope.uploader.headers["Authorization"]

                    $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
                        if $scope.uploader.getIndexOfItem(fileItem) == $scope.coverIndex
                            ProjectSheet.one(resourcesheetResult.id).patch({cover:response.resource_uri})

                    $scope.uploader.onCompleteAll = () ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})

                    $scope.uploader.uploadAll()
            )
        )
)

module.controller("MakerScienceResourceSheetCtrl", ($rootScope, $scope, $stateParams, $controller, ProjectService, TaggedItemService,
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

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0]
        $scope.objectId = $scope.projectsheet.id
        $scope.editable = $scope.projectsheet.can_edit

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
