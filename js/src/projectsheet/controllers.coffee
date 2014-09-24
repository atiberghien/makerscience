module = angular.module("projectsheet.controllers", ['projectsheet.services'])

module.controller("ProjectListCtrl", ($scope, ProjectSheet) ->
        $scope.projects = ProjectSheet.getList().$object
)

module.controller("ProjectDetailCtrl", ($scope, $stateParams, ProjectSheet) ->
        $scope.project = ProjectSheet.one($stateParams.id).get().$object
)
