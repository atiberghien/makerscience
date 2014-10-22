module = angular.module("makerscience.catalog.controllers", ['commons.graffiti.controllers'])

module.controller("MakerscienceProjectSheetCreateCtrl", ($scope, $state, $controller) ->
    console.log("MakerscienceProjectSheetCreateCtrl")
    $controller('ProjectSheetCreateCtrl', {$scope: $scope});
    
    $scope.saveMakerscienceProject = (projectsheet) ->
        console.log("MakerscienceProjectSheetCreateCtrl.save()")
        $scope.saveProject(projectsheet)
)