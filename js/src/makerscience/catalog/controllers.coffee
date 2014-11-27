module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.projects = MakerScienceProject.getList().$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.resources = MakerScienceResource.getList().$object
)

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $scope.tags = []

    $scope.saveMakerscienceProject = (projectsheet) ->
        tagsParam = []
        angular.forEach($scope.tags, (tag) ->
            tagsParam.push(tag.text)
        )

        $scope.saveProject(projectsheet).then((projectsheet) ->
            MakerScienceProject.post({'parent' : projectsheet.project, 'tags' : tagsParam}).then(->
                $state.go("project.detail", {slug : $scope.projectsheet.project.slug})
            )
        )
)

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, Tag, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $scope.preparedTags = []

    $scope.init().then((projectSheetResult) ->
        MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
            $scope.projectsheet = makerScienceProjectResult.objects[0]
            $scope.projectsheet.items = projectSheetResult.items
            $scope.projectsheet.q_a = projectSheetResult.q_a

            angular.forEach($scope.projectsheet.tags, (tag) ->
                TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/"+tag.id).then((taggdItemResult) ->
                    $scope.preparedTags.push({text : tag.name, taggedItemURI : taggdItemResult.resource_uri})
                )
            )

            $scope.similars = []
            TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((projectIDsResult) ->
                angular.forEach(projectIDsResult, (projectId) ->
                    $scope.similars.push(MakerScienceProject.one(projectId).get().$object)
                )
            )
        )
    )

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : {name: tag.text}}, "makerscienceproject/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        taggedItemID = getObjectIdFromURI(tag.taggedItemURI)
        TaggedItem.one(taggedItemID).remove()
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $scope.tags = []

    $scope.saveMakerscienceResource = (resourcesheet) ->
        tagsParam = []
        angular.forEach($scope.tags, (tag) ->
            tagsParam.push(tag.text)
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

    $scope.init().then((resourceSheetResult) ->
        MakerScienceResource.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceResourceResult) ->
            $scope.resourcesheet = makerScienceResourceResult.objects[0]
            $scope.resourcesheet.items = resourceSheetResult.items
            $scope.resourcesheet.q_a = resourceSheetResult.q_a

            angular.forEach($scope.resourcesheet.tags, (tag) ->
                TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/"+tag.id).then((taggdItemResult) ->
                    $scope.preparedTags.push({text : tag.name, taggedItemURI : taggdItemResult.resource_uri})
                )
            )

            $scope.similars = []
            TaggedItem.one().customGET("makerscienceresource/"+$scope.resourcesheet.id+"/similars").then((resourceIDsResult) ->
                angular.forEach(resourceIDsResult, (resourceId) ->
                    $scope.similars.push(MakerScienceResource.one(resourceId).get().$object)
                )
            )
        )
    )

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
