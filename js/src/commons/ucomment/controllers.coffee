module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services'])

module.controller("CommentCtrl", ($scope, $rootScope, Comment) ->
    
    console.log("==== Comments controller ====")

    $scope.newcommentForm =
        text: ""
    
    $scope.postComment = ()->
        Comment.one().customPOST({comment_text:$scope.newcommentForm.text}, $scope.resource_type+'/'+$scope.resource_id).then((newcomment)->
                console.log(" Comment posted", newcomment)
                $scope.comments.push(newcomment)
                $scope.newcommentForm.text = ''
                )
    
)