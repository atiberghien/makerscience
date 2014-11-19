module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.projects = MakerScienceProject.getList().$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.projects = MakerScienceResource.getList().$object
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
                $state.go("project.detail", {slug : $scope.projectsheet.parent.slug})
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
                TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.parent.id+"/"+tag.id).then((taggdItemResult) ->
                    $scope.preparedTags.push({text : tag.name, taggedItemURI : taggdItemResult.resource_uri})
                )
            )

            console.log($scope.projectsheet)

        )
    )

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : {name: tag.text}}, "makerscienceproject/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        taggedItemID = getObjectIdFromURI(tag.taggedItemURI)
        TaggedItem.one(taggedItemID).remove()

)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource) ->

)

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, Tag) ->

)
