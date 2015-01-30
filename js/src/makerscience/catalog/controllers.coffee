module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.projects = MakerScienceProject.getList().$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.resources = MakerScienceResource.getList().$object
)

module.controller('MakerScienceLinkedResourceAutoCompleteCtrl', ($scope, MakerScienceResource) ->

    $scope.allAvailableResources = []

    MakerScienceResource.getList().then((resourceResults)->
        angular.forEach(resourceResults, (resource) ->
            $scope.allAvailableResources.push(
                fullObject: resource
                title : resource.parent.title
            )
        )
    )
)

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject, MakerScienceResource) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $controller('MakerScienceLinkedResourceAutoCompleteCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.needTypes = ["Nouvelles idées", "Compétences", "Matériel", "Financement", "Conseils", "Avis"]
    $scope.newNeed =
        type : $scope.needTypes[0]
        description : ""
    $scope.needs = {}
    needsIndex = 0

    $scope.linkedResources = []

    $scope.saveMakerscienceProject = (projectsheet) ->
        tagsParam = []
        angular.forEach($scope.tags, (tag) ->
            tagsParam.push({name : tag.text, slug : slug(tag.text)})
        )

        $scope.saveProject(projectsheet).then((projectsheet) ->
            makerscienceProjectData =
                parent : projectsheet.project
                tags : tagsParam
                linked_resources : Object.keys($scope.linkedResources)

            MakerScienceProject.post(makerscienceProjectData).then(->
                $scope.savePhotos(projectsheet.id, projectsheet.bucket.id)
                $scope.saveVideos(projectsheet.id)

                $scope.uploader.onCompleteAll = () ->
                    $state.go("project.detail", {slug : $scope.projectsheet.project.slug})
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

    $scope.addLinkedResource = (newLinkedResource) ->
        if newLinkedResource && $scope.linkedResources.indexOf(newLinkedResource.originalObject.fullObject) < 0
            $scope.linkedResources.push(newLinkedResource.originalObject.fullObject)
            $scope.newLinkedResource = null
            $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea')

    $scope.delLinkedResource = (resource) ->
        resourceIndex = $scope.linkedResources.indexOf(resource)
        $scope.linkedResources.pop(resourceIndex)

)

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, MakerScienceResource, Tag, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('MakerScienceLinkedResourceAutoCompleteCtrl', {$scope: $scope})

    $scope.preparedTags = []
    $scope.linkedResources = []

    MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
        $scope.projectsheet = makerScienceProjectResult.objects[0]
        $scope.linkedResources = angular.copy($scope.projectsheet.linked_resources)

        angular.forEach($scope.projectsheet.tags, (tag) ->
            TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/"+tag.id).then((taggdItemResult) ->
                $scope.preparedTags.push({text : tag.name, taggedItemURI : taggdItemResult.resource_uri})
            )
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceproject'
                    $scope.similars.push(MakerScienceProject.one(similar.id).get().$object)
            )
        )
    )

    $scope.updateMakerScienceProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'MakerScienceProject' then MakerScienceProject.one(resourceId).patch(putData)

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : {name: tag.text}}, "makerscienceproject/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        taggedItemID = getObjectIdFromURI(tag.taggedItemURI)
        TaggedItem.one(taggedItemID).remove()


    $scope.addLinkedResource = (newLinkedResource) ->
        resource = newLinkedResource.originalObject.fullObject
        if newLinkedResource && $scope.linkedResources.indexOf(resource) < 0
            $scope.linkedResources.push(resource)
            $scope.projectsheet.linked_resources.push(resource.resource_uri)
            $scope.newLinkedResource = null
            MakerScienceProject.one($scope.projectsheet.id).patch({linked_resources : $scope.projectsheet.linked_resources})
            $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea')

    $scope.delLinkedResource = (resource) ->
        resourceIndex = $scope.linkedResources.indexOf(resource)
        $scope.linkedResources.pop(resourceIndex)
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $scope.tags = []

    $scope.saveMakerscienceResource = (resourcesheet) ->
        tagsParam = []
        angular.forEach($scope.tags, (tag) ->
            tagsParam.push({name : tag.text, slug : slug(tag.text)})
        )

        $scope.saveProject(resourcesheet).then((resourcesheet) ->
            MakerScienceResource.post({'parent' : resourcesheet.project, 'tags' : tagsParam}).then(->
                $state.go("resource.detail", {slug : $scope.resourcesheet.project.slug})
            )
        )
)

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, Tag, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})

    $scope.preparedTags = []

    MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
        $scope.resourcesheet = makerScienceResourceResult.objects[0]
        angular.forEach($scope.resourcesheet.tags, (tag) ->
            TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/"+tag.id).then((taggdItemResult) ->
                $scope.preparedTags.push({text : tag.name, taggedItemURI : taggdItemResult.resource_uri})
            )
        )

        $scope.similars = []
        TaggedItem.one().customGET("makerscienceresource/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
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

    $scope.addTagFromResource = (tag) ->
        TaggedItem.one().customPOST({tag : {name: tag.text}}, "makerscienceresource/"+$scope.resource.id, {})

    $scope.removeTagFromResource = (tag) ->
        taggedItemID = getObjectIdFromURI(tag.taggedItemURI)
        TaggedItem.one(taggedItemID).remove()
)


module.controller("ResourceLevelCtrl", ($scope) ->
    $scope.level = 1
    $scope.selectedClasses = {"1" : "selected"}

    $scope.updateLevelChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice] = "selected"
)
