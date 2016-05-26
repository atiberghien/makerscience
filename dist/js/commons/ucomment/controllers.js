(function() {
  var module;

  module = angular.module("commons.ucomment.controllers", ['commons.ucomment.services', 'makerscience.base.services']);

  module.controller("CommentCtrl", function($scope, $rootScope, Comment, Profile, ObjectProfileLink, DataSharing) {
    "controlling comments attached to a resource.";
    $scope.newcommentForm = {
      text: ""
    };
    $scope.initCommentCtrl = function(objectTypeName, objectID) {
      $scope.commentedObjectTypeName = objectTypeName;
      $scope.commentedObjectID = objectID;
      console.log($scope.commentedObjectTypeName, $scope.commentedObjectID);
      return $scope.refreshComments();
    };
    $scope.refreshComments = function(objectTypeName, objectId) {
      return $scope.comments = Comment.one().customGETLIST($scope.commentedObjectTypeName + '/' + $scope.commentedObjectID).$object;
    };
    $scope.isCommentAuthor = function(comment) {
      "To check wether connected user is comment's author";
      return $rootScope.authVars.username === comment.user.username;
    };
    $scope.removeComment = function(index) {
      "Remove comment placed at scope array index";
      return Comment.one($scope.comments[index].id).remove().then(function(data) {
        return $scope.comments.splice(index, 1);
      });
    };
    $scope.flagComment = function(index) {
      return Comment.one($scope.comments[index].id).customPOST({}, 'flag/').then(function(data) {
        return $scope.comments[index].flags.push({
          flag: 'flagged'
        });
      });
    };
    return $scope.postComment = function(commentType) {
      return Comment.one().customPOST({
        comment_text: $scope.newcommentForm.text
      }, $scope.commentedObjectTypeName + '/' + $scope.commentedObjectID).then(function(newcomment) {
        $scope.comments.push(newcomment);
        $scope.newcommentForm.text = '';
        $scope.commenting = false;
        return Profile.one().get({
          user__id: newcomment.user.id
        }).then(function(profileResults) {
          var profile;
          if (profileResults.objects.length === 1) {
            profile = profileResults.objects[0];
            return ObjectProfileLink.one().customPOST({
              profile_id: profile.id,
              level: commentType,
              detail: '',
              isValidated: true
            }, $scope.commentedObjectTypeName + '/' + $scope.commentedObjectID);
          }
        });
      });
    };
  });

}).call(this);
