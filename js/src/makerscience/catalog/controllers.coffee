module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services',
            'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services',
            'makerscience.base.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, $controller, MakerScienceProject) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.projects = MakerScienceProject.one().customGETLIST('search', $scope.params).$object

)

module.controller("MakerScienceResourceListCtrl", ($scope, $controller, MakerScienceResource) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.resources = MakerScienceResource.one().customGETLIST('search', $scope.params).$object
)

module.controller('MakerScienceLinkedResourceCtrl', ($scope, MakerScienceResource) ->

    $scope.allAvailableResources = []
    $scope.linkedResources = []

    MakerScienceResource.getList().then((resourceResults)->
        angular.forEach(resourceResults, (resource) ->
            $scope.allAvailableResources.push(
                fullObject: resource
                title : resource.parent.title
            )
        )
    )

    $scope.delLinkedResource = (resource) ->
        resourceIndex = $scope.linkedResources.indexOf(resource)
        $scope.linkedResources.pop(resourceIndex)

    $scope.addLinkedResource = (newLinkedResource) ->
        resource = newLinkedResource.originalObject.fullObject
        if newLinkedResource && $scope.linkedResources.indexOf(resource) < 0
            $scope.linkedResources.push(resource)
            $scope.newLinkedResource = null
            $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea')
)

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, $filter, ProjectProgress,
                                                        MakerScienceProject, MakerScienceResource, MakerScienceProjectTaggedItem, ObjectProfileLink) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.needTypes = ["Nouvelles idées", "Compétences", "Matériel", "Financement", "Conseils", "Avis"]
    $scope.newNeed =
        type : $scope.needTypes[0]
        description : ""
    $scope.needs = {}
    needsIndex = 0

    ProjectProgress.getList({'range__slug' : 'makerscience'}).then((progressRangeResult) ->
        $scope.progressRange = [{ value : progress.resource_uri, text : progress.label } for progress in $filter('orderBy')(progressRangeResult, 'order')][0]
    )

    $scope.saveMakerscienceProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")


        $scope.saveProject().then((projectsheetResult) ->

            console.log(" Just saved project : Result from savingProject : ", projectsheetResult)
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
                , 'project/'+makerscienceProjectResult.parent.id).then((objectProfileLinkResult) ->
                    console.log("added current user as team member", objectProfileLinkResult.profile)
                    MakerScienceProject.one(makerscienceProjectResult.id).customPOST({"user_id":objectProfileLinkResult.profile.user.id}, 'assign').then((result)->
                        console.log(" succesfully assigned edit rights ? : ", result)
                        )
                )
                angular.forEach($scope.themesTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/th", {})
                )

                angular.forEach($scope.formatsTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/fm", {})
                )

                angular.forEach($scope.targetsTags, (tag)->
                    MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id+"/tg", {})
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

    $scope.addNeed = (newNeed) ->
        if newNeed.type && newNeed.description
            $scope.needs[needsIndex] = newNeed
            $scope.newNeed =
                type : $scope.needTypes[0]
                description : ""
            needsIndex += 1

    $scope.delNeed = (index) ->
        delete $scope.needs[index]
)


module.controller("MakerScienceProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, $filter,
                                                    MakerScienceProject, MakerScienceResource,
                                                    MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress
                                                    Comment, ObjectProfileLink, DataSharing) ->

    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.preparedThemeTags = []
    $scope.preparedFormatsTags = []
    $scope.preparedTargetTags = []

    $scope.currentUserHasEditRights = false
    $scope.editable = false


    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]

        if $rootScope.authVars.user
            console.log("Check if", $rootScope.authVars.user.id, "has right.")
            MakerScienceProject.one($scope.projectsheet.id).one('check', $rootScope.authVars.user.id).get().then((result)->
                console.log(" Has current user edit rights ?", result.has_perm)
                $scope.currentUserHasEditRights = result.has_perm
                $scope.editable = result.has_perm

        )
        # FIXME : these 2 signals should be removed, since we now use DataSharing service
        # $scope.$broadcast('projectReady', {project : $scope.projectsheet.parent})
        # $scope.$broadcast('makerscienceprojectReady', {makerscienceproject : $scope.projectsheet})

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
                when "th" then $scope.preparedThemeTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "tg" then $scope.preparedTargetTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "fm" then $scope.preparedFormatsTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToProjectSheet = (tag_type, tag) ->
            MakerScienceProjectTaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+$scope.projectsheet.id+"/"+tag_type, {})

        $scope.removeTagFromProjectSheet = (tag) ->
            MakerScienceProjectTaggedItem.one(tag.taggedItemId).remove()


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

    )

    $scope.updateMakerScienceProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceProject' then MakerScienceProject.one(resourceId).patch(putData)
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource, MakerScienceResourceTaggedItem, ObjectProfileLink) ->
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
            console.log("Just saved project for resoure sheet, result: ", resourcesheetResult)
            makerscienceResourceData =
                duration : $scope.projectsheet.duration
                parent : resourcesheetResult.project.resource_uri
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                console.log("Posting MakerScienceResource, result  : ", makerscienceResourceResult)
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 0,
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
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/th", {})
                )

                angular.forEach($scope.formatsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/fm", {})
                )

                angular.forEach($scope.targetsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/tg", {})
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
                                                    Comment, DataSharing) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

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
        # FIXME : remove 2 signals below, > now using service + $watch to share and sync data
        # $scope.$broadcast('projectReady', {project : $scope.projectsheet.parent})
        # $scope.$broadcast('makerscienceresourceReady', {makerscienceresource : $scope.projectsheet})

        console.log("before setting datasharing", DataSharing.sharedObject)
        DataSharing.sharedObject =  {project : $scope.projectsheet.parent, makerscienceresource : $scope.projectsheet}
        console.log("AFTER setting datasharing", DataSharing.sharedObject)

        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "th" then $scope.preparedThemeTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "tg" then $scope.preparedTargetTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "fm" then $scope.preparedFormatsTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToResourceSheet = (tag_type, tag) ->
            MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+$scope.projectsheet.id+"/"+tag_type, {})

        $scope.removeTagFromResourceSheet = (tag) ->
            MakerScienceResourceTaggedItem.one(tag.taggedItemId).remove()

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceresource'
                    $scope.similars.push(MakerScienceResource.one(similar.id).get().$object)
            )
        )

        $scope.$on('newTeamMember', (event, user_id)->
            """
            Give edit rights to newly added or validated team member (see commons.accounts.controllers)
            """
            console.log(" giving edit rights to user id = ", user_id)
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
    )

    $scope.updateMakerScienceResourceSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceResource' then MakerScienceResource.one(resourceId).patch(putData)
)


module.controller("ResourceLevelCtrl", ($scope) ->
    $scope.level = 1
    $scope.selectedClasses = {"1" : "selected"}

    $scope.updateLevelChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice] = "selected"
)
