module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerscienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject) ->
    console.log("MakerscienceProjectSheetCreateCtrl")
    $controller('ProjectSheetCreateCtrl', {$scope: $scope});

    $scope.saveMakerscienceProject = (projectsheet) ->
        console.log("MakerscienceProjectSheetCreateCtrl.save()")
        $scope.saveProject(projectsheet).then((parent_uri) ->
            MakerScienceProject.post({'parent' : parent_uri, 'tags' : ['tag1', 'tag2', 'tag3', 'tag4']})
            # $state.go("projectsheet", {slug : $scope.projectsheet.project.slug})
        )
)
