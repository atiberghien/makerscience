module = angular.module("makerscience.catalog.controllers.project", ['makerscience.catalog.services', "makerscience.catalog.controllers.generic",
            'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services',
            'makerscience.base.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, $controller, MakerScienceProject, MakerScienceProjectTaggedItem) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.fetchRecentProjects = () ->
        $scope.params['ordering'] = '-created_on'
        $scope.refreshList()

    $scope.fetchTopProjects = () ->
        $scope.params['ordering'] = '-total_score'
        $scope.refreshList()

    $scope.fetchRandomProjects = () ->
        $scope.params['ordering'] = ''
        $scope.refreshList().then(->
            nbElmt = $scope.projects.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.projects[nbElmt]
                $scope.projects[nbElmt] = $scope.projects[rand]
                $scope.projects[rand] = tmp
        )

    $scope.refreshList = ()->
        return MakerScienceProject.one().customGETLIST('search', $scope.params).then((makerScienceProjectResults) ->
            meta = makerScienceProjectResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.projects =  makerScienceProjectResults
        )

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

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, ProjectProgress,
                                                        MakerScienceProject, MakerScienceResource, MakerScienceProjectTaggedItem, ObjectProfileLink) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.saveMakerscienceProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")

        $scope.saveProject().then((projectsheetResult) ->
            makerscienceProjectData =
                parent : projectsheetResult.project.resource_uri
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceProject.post(makerscienceProjectData).then((makerscienceProjectResult)->
                console.log(" Posting MakerScienceProject, result from savingProject : ", makerscienceProjectResult)
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 0,
                    detail : "Créateur/Créatrice",
                    isValidated:true
                , 'makerscienceproject/'+makerscienceProjectResult.id).then((objectProfileLinkResult) ->
                    console.log("added current user as team member", objectProfileLinkResult.profile)
                    MakerScienceProject.one(makerscienceProjectResult.id).customPOST({"user_id":objectProfileLinkResult.profile.user.id}, 'assign').then((result)->
                        console.log(" succesfully assigned edit rights ? : ", result)
                        )
                )
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

                $scope.saveVideos(projectsheetResult.id)
                # if no photos to upload, directly go to new project sheet
                if $scope.uploader.queue.length <= 0
                    $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})
                else
                    $scope.savePhotos(projectsheetResult.id, projectsheetResult.bucket.id)
                    $scope.uploader.onCompleteAll = () ->
                        $state.go("project.detail", {slug : makerscienceProjectResult.parent.slug})
            )
        )
)

module.controller("MakerScienceProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $filter,
                                                    MakerScienceProject, MakerScienceResource,
                                                    MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress
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

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]

        if $rootScope.authVars.user
            MakerScienceProject.one($scope.projectsheet.id).one('check', $rootScope.authVars.user.id).get().then((result)->
                console.log(" Has current user edit rights ?", result.has_perm)
                $scope.currentUserHasEditRights = result.has_perm
                $scope.editable = result.has_perm

        )

        console.log("Before setting datasharing", DataSharing.sharedObject)
        DataSharing.sharedObject =  {project: $scope.projectsheet.parent, makerscienceproject : $scope.projectsheet}
        console.log("After setting datasharing", DataSharing.sharedObject)

        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceproject'
                    $scope.similars.push(MakerScienceProject.one(similar.id).get().$object)
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
                MakerScienceProject.one($scope.projectsheet.id).customPOST({"user_id":user_id}, 'assign').then((result)->
                    console.log(" succesfully assigned edit rights ? : ", result)
                    )
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
                return if $scope.projectsheet.parent.progress.label && selected.length then selected[0].text else 'non renseigné';
        )

        $scope.removeTagFromProjectSheet = (tag) ->
            MakerScienceProjectTaggedItem.one(tag.taggedItemId).remove()

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
                    )

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
