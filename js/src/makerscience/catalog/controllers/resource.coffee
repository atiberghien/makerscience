module = angular.module("makerscience.catalog.controllers.resource", ['makerscience.catalog.services', "makerscience.catalog.controllers.generic",
            'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services',
            'makerscience.base.controllers'])

module.controller("MakerScienceResourceListCtrl", ($scope, $controller, MakerScienceResource, MakerScienceResourceTaggedItem) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.fetchRecentResources = () ->
        $scope.params['ordering'] = '-created_on'
        $scope.refreshList()

    $scope.fetchTopResources = () ->
        $scope.params['ordering'] = '-total_score'
        $scope.refreshList()

    $scope.fetchRandomResources = () ->
        $scope.params['ordering'] = ''
        $scope.refreshList().then(->
            nbElmt = $scope.resources.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.resources[nbElmt]
                $scope.resources[nbElmt] = $scope.resources[rand]
                $scope.resources[rand] = tmp
        )

    $scope.refreshList = ()->
        return MakerScienceResource.one().customGETLIST('search', $scope.params).then((makerScienceResourceResults) ->
            meta = makerScienceResourceResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.resources =  makerScienceResourceResults
        )

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

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller,
                             MakerScienceResource, MakerScienceResourceTaggedItem, ObjectProfileLink) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.saveMakerscienceResource = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")

        $scope.saveProject().then((resourcesheetResult) ->
            makerscienceResourceData =
                parent : resourcesheetResult.project.resource_uri
                duration : $scope.projectsheet.duration
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                console.log("Posting MakerScienceResource, result  : ", makerscienceResourceResult)
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 10,
                    detail : "Créateur/Créatrice",
                    isValidated:true
                    , 'project/'+makerscienceResourceResult.parent.id).then((objectProfileLinkResult) ->
                        console.log("added current user as team member", objectProfileLinkResult.profile)
                        MakerScienceResource.one(makerscienceResourceResult.id).customPOST(
                            {"user_id":objectProfileLinkResult.profile.user.id}
                            , 'assign').then((result)->
                                console.log("Succesfully assigned edit rights ? : ", result)
                        )
                    )

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

                $scope.saveVideos(resourcesheetResult.id)
                # if no photos to upload, directly go to new project sheet
                if $scope.uploader.queue.length <= 0
                    $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
                else
                    $scope.savePhotos(resourcesheetResult.id, resourcesheetResult.bucket.id)
                    $scope.uploader.onCompleteAll = () ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
            )
        )
)

module.controller("MakerScienceResourceSheetCtrl", ($rootScope, $scope, $stateParams, $controller,
                                                    MakerScienceResource, MakerScienceResourceTaggedItem, TaggedItem,
                                                    Comment, ObjectProfileLink, DataSharing) ->

    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})
    $controller('VoteCtrl', {$scope: $scope})

    $scope.preparedThemeTags = []
    $scope.preparedFormatsTags = []
    $scope.preparedTargetTags = []

    $scope.currentUserHasEditRights = false
    $scope.editable = false

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0]

        if $rootScope.authVars.user
            MakerScienceResource.one($scope.projectsheet.id).one('check', $rootScope.authVars.user.id).get().then((result)->
                console.log(" Has current user edit rights ?", result.has_perm)
                $scope.currentUserHasEditRights = result.has_perm
                $scope.editable = result.has_perm

        )

        console.log("before setting datasharing", DataSharing.sharedObject)
        DataSharing.sharedObject =  {project : $scope.projectsheet.parent, makerscienceresource : $scope.projectsheet}
        console.log("AFTER setting datasharing", DataSharing.sharedObject)

        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceresource'
                    $scope.similars.push(MakerScienceResource.one(similar.id).get().$object)
            )
        )

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "th" then $scope.preparedThemeTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug, taggedItemId : taggedItem.id})
                when "tg" then $scope.preparedTargetTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
                when "fm" then $scope.preparedFormatsTags.push({text : taggedItem.tag.name, slug : taggedItem.tag.slug,  taggedItemId : taggedItem.id})
        )

        $scope.$on('newTeamMember', (event, user_id)->
                """
                Give edit rights to newly added or validated team member (see commons.accounts.controllers)
                """
                console.log("Giving edit rights to user id = ", user_id)
                MakerScienceResource.one($scope.projectsheet.id).customPOST({"user_id":user_id}, 'assign').then((result)->
                    console.log(" succesfully assigned edit rights ? : ", result)
                    )
            )

        $scope.updateLinkedResources = ->
            MakerScienceResource.one($scope.projectsheet.id).patch(
                linked_resources : $scope.linkedResources.map((resource) ->
                    return resource.resource_uri
                )
            )
        $scope.removeTagFromResourceSheet = (tag) ->
            MakerScienceResourceTaggedItem.one(tag.taggedItemId).remove()

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
                    )

                $scope.saveMakerScienceResourceVote = (voteType, score) ->
                    # profileID, objectTypeName, objectID, voteType, score, objectProfileLinkType
                    $scope.saveVote($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id, voteType, score, 4)

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
