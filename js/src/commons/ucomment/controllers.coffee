module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services', 'makerscience.base.services'])

module.controller("CommentCtrl", ($scope, $rootScope, Comment, Profile, ObjectProfileLink, DataSharing) ->
    """
    controlling comments attached to a resource.
    """

    $scope.newcommentForm =
        text: ""

    $scope.initCommentCtrl = (objectTypeName, objectID) ->
        $scope.commentedObjectTypeName = objectTypeName
        $scope.commentedObjectID = objectID
        $scope.refreshComments()

    $scope.refreshComments = (objectTypeName, objectId) ->
        $scope.comments = Comment.one().customGETLIST($scope.commentedObjectTypeName+'/'+$scope.commentedObjectID).$object

    $scope.isCommentAuthor = (comment)->
        """
        To check wether connected user is comment's author
        """
        return $rootScope.authVars.username == comment.user.username

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


    $scope.postComment = (commentType)->
        Comment.one().customPOST({comment_text:$scope.newcommentForm.text}, $scope.commentedObjectTypeName+'/'+$scope.commentedObjectID).then((newcomment)->
            $scope.comments.push(newcomment)
            $scope.newcommentForm.text = ''
            $scope.commenting = false

            Profile.one().get({user__id : newcomment.user.id}).then((profileResults) ->
                if profileResults.objects.length == 1
                    profile = profileResults.objects[0]
                    ObjectProfileLink.one().customPOST(
                        profile_id: profile.id,
                        level: commentType,
                        detail : '',
                        isValidated:true
                    , $scope.commentedObjectTypeName+'/'+$scope.commentedObjectID)
            )
        )

)
