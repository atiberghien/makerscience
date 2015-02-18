module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services'])

module.controller("CommentCtrl", ($scope, $rootScope, Comment) ->
    
    console.log("==== Comments controller ====")

    $scope.newcommentForm =
        text: ""
    
    $scope.isCommentAuthor = (comment)->
        """
        To check wether connected user is comment's author
        """
        if $rootScope.authVars.username == comment.user.username
            return true
        else
            return false

    $scope.removeComment = (index)->
        """
        Remove comment placed at scope array index 
        """
        Comment.one($scope.comments[index].id).remove().then((data)->
            console.log(" comment removed", data)
            $scope.comments.splice(index, 1)
            )

    $scope.flagComment = (index)->
        Comment.one($scope.comments[index].id).customPOST({}, 'flag/').then((data)->
            console.log(" comment flagged", data)
            $scope.comments[index].flags.push({flag:'flagged'}) 
            )


    $scope.postComment = ()->
        Comment.one().customPOST({comment_text:$scope.newcommentForm.text}, $scope.resource_type+'/'+$scope.resource_id).then((newcomment)->
                console.log(" Comment posted", newcomment)
                $scope.comments.push(newcomment)
                $scope.newcommentForm.text = ''
                $scope.commenting = false
                )
    
)