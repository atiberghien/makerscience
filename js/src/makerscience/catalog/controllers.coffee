module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.projects = MakerScienceProject.getList().$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.resources = MakerScienceResource.getList().$object
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


    $scope.saveMakerscienceProject = () ->
        $scope.saveProject().then((projectsheetResult) ->
            makerscienceProjectData =
                parent : projectsheetResult.project
                linked_resources : $scope.linkedResources.map((resource) ->
                        return resource.resource_uri
                    )

            MakerScienceProject.post(makerscienceProjectData).then((makerscienceProjectResult)->
                angular.forEach($scope.tags, (tag)->
                    TaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+makerscienceProjectResult.id, {})
                )
                $scope.savePhotos(projectsheetResult.id, projectsheetResult.bucket.id)
                $scope.saveVideos(projectsheetResult.id)

                $scope.uploader.onCompleteAll = () ->
                    $state.go("project.detail", {slug : projectsheetResult.project.slug})
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

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, MakerScienceResource, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('MakerScienceLinkedResourceCtrl', {$scope: $scope})

    $scope.preparedTags = []

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]
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

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : tag.text}, "makerscienceproject/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        TaggedItem.one(tag.taggedItemId).remove()
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource, TaggedItem) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.saveMakerscienceResource = () ->
        $scope.saveProject().then((resourcesheetResult) ->
            makerscienceResourceData =
                level : $scope.projectsheet.level
                duration : $scope.projectsheet.duration
                cost : $scope.projectsheet.cost
                parent : resourcesheetResult.project

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                angular.forEach($scope.tags, (tag)->
                    TaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id, {})
                )
                # $state.go("resource.detail", {slug : $scope.projectsheet.project.slug})
            )
        )
)

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})

    $scope.preparedTags = []

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0]

        angular.forEach($scope.projectsheet.tags, (taggedItem) ->
            $scope.preparedTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceresource'
                    $scope.similars.push(MakerScienceProject.one(similar.id).get().$object)
            )
        )
    )

    $scope.updateMakerScienceResourceSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceResource' then MakerScienceResource.one(resourceId).patch(putData)

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        TaggedItem.one(tag.taggedItemId).remove()
)


module.controller("ResourceLevelCtrl", ($scope) ->
    $scope.level = 1
    $scope.selectedClasses = {"1" : "selected"}

    $scope.updateLevelChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice] = "selected"
)
