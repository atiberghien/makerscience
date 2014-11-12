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
                $state.go("projectsheet", {slug : $scope.projectsheet.project.slug})
            )
        )
)

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, Tag) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})

    $scope.init().then( ->
        $scope.projectsheet.tags = []
        MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
            project = makerScienceProjectResult.objects[0]
            angular.forEach(project.tags, (tagURI) ->
                tagID = getObjectIdFromURI(tagURI)
                Tag.one(tagID).get().then((tagResult) ->
                    $scope.projectsheet.tags.push(tagResult)
                )
            )
            $scope.projectsheet.modified = project.modified
        )
    )
)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource) ->

)

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, Tag) ->

)
