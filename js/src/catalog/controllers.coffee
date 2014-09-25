module = angular.module("projectsheet.controllers", ['projectsheet.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
	$scope.projects = Project.getList().$object
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, ProjectSheet) ->
        ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((res) -> 
        		$scope.projectsheet =  res.objects[0]
        )
)