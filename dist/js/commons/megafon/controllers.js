(function() {
  var module;

  module = angular.module("commons.megafon.controllers", ['commons.megafon.services']);

  module.controller("PostCreateCtrl", function($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) {
    $scope.questionTags = [];
    return $scope.savePost = function(newPost, parent, authorProfile) {
      if (parent) {
        newPost["parent"] = parent.resource_uri;
      }
      return Post.post(newPost).then(function(postResult) {
        angular.forEach($scope.questionTags, function(tag) {
          return TaggedItem.one().customPOST({
            tag: tag.text
          }, "post/" + postResult.id, {});
        });
        ObjectProfileLink.one().customPOST({
          profile_id: authorProfile.id,
          level: 30,
          detail: "Auteur du post #" + postResult.id,
          isValidated: true
        }, 'post/' + postResult.id);
        if (parent) {
          ObjectProfileLink.one().customPOST({
            profile_id: authorProfile.id,
            level: 31,
            detail: "Contributeur du post #" + postResult.id,
            isValidated: true
          }, 'post/' + parent.id);
        }
        return postResult;
      });
    };
  });

  module.controller("PostCtrl", function($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) {
    $scope.getContributors = function(postID) {
      var contributorsIdx;
      $scope["contributors" + postID] = [];
      contributorsIdx = [];
      return ObjectProfileLink.one().customGET('post/' + postID, {
        level: 31
      }).then(function(objectProfileLinkResults) {
        angular.forEach(objectProfileLinkResults.objects, function(objectProfileLink) {
          if (contributorsIdx.indexOf(objectProfileLink.profile.id) === -1) {
            contributorsIdx.push(objectProfileLink.profile.id);
            return $scope["contributors" + postID].push(objectProfileLink.profile);
          }
        });
        return $scope["contributors" + postID];
      });
    };
    $scope.getSimilars = function(postID) {
      $scope["similars" + postID] = [];
      return TaggedItem.one().customGET("post/" + postID + "/similars").then(function(similarResults) {
        angular.forEach(similarResults, function(similar) {
          if (similar.type === 'post') {
            return Post.one(similar.id).get().then(function(postResult) {
              return $scope["similars" + postID].push(postResult);
            });
          }
        });
        return $scope["similars" + postID];
      });
    };
    $scope.getPostAuthor = function(postID) {
      return ObjectProfileLink.one().customGET('post/' + postID, {
        level: 30
      }).then(function(objectProfileLinkResults) {
        if (objectProfileLinkResults.objects.length === 1) {
          $scope["post" + postID + "Author"] = objectProfileLinkResults.objects[0].profile;
        } else {
          $scope["post" + postID + "Author"] = null;
        }
        return $scope["post" + postID + "Author"];
      });
    };
    $scope.fetchAuthors = function(post) {
      return $scope.getPostAuthor(post.id).then(function(author) {
        post.author = author;
        return angular.forEach(post.answers, function(answer) {
          return $scope.fetchAuthors(answer);
        });
      });
    };
    $scope.fetchContributors = function(post) {
      return $scope.getContributors(post.id).then(function(contributors) {
        post.contributors = contributors;
        return angular.forEach(post.answers, function(answer) {
          return $scope.fetchContributors(answer);
        });
      });
    };
    $scope.getLikes = function(postID) {
      return ObjectProfileLink.one().get({
        level: 34,
        content_type: 'post',
        object_id: postID
      });
    };
    return $scope.fetchPostLikes = function(post) {
      return $scope.getLikes(post.id).then(function(likes) {
        post.likes = likes.objects;
        return angular.forEach(post.answers, function(answer) {
          return $scope.fetchPostLikes(answer);
        });
      });
    };
  });

}).call(this);
