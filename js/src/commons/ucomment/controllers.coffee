module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services'])

module.controller("CommentCtrl", ($scope, Comment) ->
    
    console.log("==== Comments controller ====")
    $scope.object_type = 'makerscienceproject' # FIXME: get it from parent scope
    $scope.object_id = $scope.$parent.projectsheet.id # FIXME : make it generic for makerscience resources or even comments themselves
    $scope.comments = Comment.one($scope.object_type, $scope.object_id).getList().$object
    
)