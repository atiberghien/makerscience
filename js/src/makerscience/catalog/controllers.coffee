module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.limit = 12

    $scope.init = (limit, featured) ->
        params = {}
        if limit
             $scope.limit = limit
        if featured
            params['featured'] = featured
        params['limit'] = $scope.limit
        $scope.projects = MakerScienceProject.getList(params).$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.limit = 1000

    $scope.init = (limit, featured) ->
        if limit
            $scope.limit = limit
        $scope.resources = MakerScienceResource.getList({limit:$scope.limit}).$object
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

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject, MakerScienceResource, TaggedItem) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.needTypes = ["Nouvelles idées", "Compétences", "Matériel", "Financement", "Conseils", "Avis"]
    $scope.newNeed =
        type : $scope.needTypes[0]
        description : ""
    $scope.needs = {}
    needsIndex = 0


    $scope.saveMakerscienceProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")
        $scope.saveProject().then((projectsheetResult) ->
            console.log(" Just saved project : Result from savingProject : ", projectsheetResult)
            makerscienceProjectData =
                parent : projectsheetResult.project
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceProject.post(makerscienceProjectData).then((makerscienceProjectResult)->
                console.log(" Posting MakerScienceProject, result from savingProject : ", projectsheetResult)
                angular.forEach($scope.tags, (tag)->
                    TaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id, {})
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

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, MakerScienceResource, TaggedItem, Comment, ObjectProfileLink, DataSharing) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.preparedTags = []

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]

        # FIXME : these 2 signals should be removed, since we now use DataSharing service
        $scope.$broadcast('projectReady', {project : $scope.projectsheet.parent})
        $scope.$broadcast('makerscienceprojectReady', {makerscienceproject : $scope.projectsheet})
        
        console.log("before setting datasharing", DataSharing.sharedObject)
        DataSharing.sharedObject =  {project: $scope.projectsheet.parent, makerscienceproject : $scope.projectsheet}
        console.log("AFTER setting datasharing", DataSharing.sharedObject)

        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            $scope.preparedTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceproject'
                    $scope.similars.push(MakerScienceProject.one(similar.id).get().$object)
            )
        )

        $scope.updateLinkedResources = ->
            MakerScienceProject.one($scope.projectsheet.id).patch(
                linked_resources : $scope.linkedResources.map((resource) ->
                    return resource.resource_uri
                )
            )
    )

    $scope.updateMakerScienceProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceProject' then MakerScienceProject.one(resourceId).patch(putData)
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource, TaggedItem) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.saveMakerscienceResource = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")

        $scope.saveProject().then((resourcesheetResult) ->
            console.log(" Just saved project for resoure sheet, result: ", resourcesheetResult)
            makerscienceResourceData =
                level : $scope.projectsheet.level
                duration : $scope.projectsheet.duration
                cost : $scope.projectsheet.cost
                parent : resourcesheetResult.project
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                console.log(" Posting MakerScienceResource, result  : ", makerscienceResourceResult)
                angular.forEach($scope.tags, (tag)->
                    TaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id, {})
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

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, TaggedItem, Comment, DataSharing) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.preparedTags = []

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0]

        # FIXME : remove 2 signals below, > now using service + $watch to share and sync data
        $scope.$broadcast('projectReady', {project : $scope.projectsheet.parent})
        $scope.$broadcast('makerscienceresourceReady', {makerscienceresource : $scope.projectsheet})
        
        console.log("before setting datasharing", DataSharing.sharedObject)
        DataSharing.sharedObject =  {project : $scope.projectsheet.parent, makerscienceresource : $scope.projectsheet}
        console.log("AFTER setting datasharing", DataSharing.sharedObject)

        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            $scope.preparedTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceresource'
                    $scope.similars.push(MakerScienceResource.one(similar.id).get().$object)
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
