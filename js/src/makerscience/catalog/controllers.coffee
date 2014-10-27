module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerscienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject) ->
    console.log("MakerscienceProjectSheetCreateCtrl")
    $controller('ProjectSheetCreateCtrl', {$scope: $scope});

    $scope.saveMakerscienceProject = (projectsheet) ->
        console.log("MakerscienceProjectSheetCreateCtrl.save()")
        $scope.saveProject(projectsheet).then((parent_uri) ->
            MakerScienceProject.post({'parent' : parent_uri, 'tags' : ['plop', 'pipi', 'caca', 'prout   ']})
            # $state.go("projectsheet", {slug : $scope.projectsheet.project.slug})
        )
)
