module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services'])

module.controller("CommentCtrl", ($scope, $rootScope, Comment) ->
    """
    controlling comments attached to a resource. Requires that parent scope has:
    - $scope.comments
    """

    $scope.newcommentForm =
        text: ""

    $scope.init = (objectTypeName) ->
        $scope.$on(objectTypeName+'Ready', (event, args) ->
            $scope.objectTypeName = objectTypeName
            $scope.object = args[objectTypeName]
            $scope.refreshComments($scope.objectTypeName, $scope.object.id)
        )

    $scope.refreshComments = (objectTypeName, objectId) ->
        $scope.comments = Comment.one().customGETLIST(objectTypeName+'/'+objectId).$object

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
            $scope.comments.splice(index, 1)
            )

    $scope.flagComment = (index)->
        Comment.one($scope.comments[index].id).customPOST({}, 'flag/').then((data)->
            $scope.comments[index].flags.push({flag:'flagged'})
            )


    $scope.postComment = ()->
        Comment.one().customPOST({comment_text:$scope.newcommentForm.text}, $scope.objectTypeName+'/'+$scope.object.id).then((newcomment)->
                $scope.comments.push(newcomment)
                $scope.newcommentForm.text = ''
                $scope.commenting = false
                )

)
