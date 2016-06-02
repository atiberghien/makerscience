(function() {
  var module;

  module = angular.module("makerscience.forum.controllers", ["commons.megafon.controllers", 'makerscience.base.services', 'makerscience.base.controllers']);

  module.controller("MentionCtrl", function($scope, MakerScienceProfile) {
    $scope.people = [];
    $scope.initMention = function(iframeElement) {
      return $scope.tinyMceOptions["init_instance_callback"] = function(editor) {
        return $scope[iframeElement] = editor.iframeElement;
      };
    };
    $scope.searchPeople = function(mentionTerm) {
      if (mentionTerm.length > 2) {
        return MakerScienceProfile.one().customGETLIST('search', {
          q: '*' + mentionTerm + '*'
        }).then(function(makerScienceProfileResults) {
          return $scope.people = makerScienceProfileResults;
        });
      }
    };
    return $scope.getPeopleTextRaw = function(mentionnedProfile) {
      return "@" + mentionnedProfile.slug;
    };
  });

  module.controller("MakerSciencePostCreateCtrl", function($scope, $controller, $filter, MakerSciencePost, MakerScienceProfile, ObjectProfileLink, MakerScienceProjectLight, MakerScienceResourceLight, TaggedItem) {
    angular.extend(this, $controller('PostCreateCtrl', {
      $scope: $scope
    }));
    $scope.allAvailableItems = [];
    MakerScienceProjectLight.getList().then(function(projectResults) {
      return angular.forEach(projectResults, function(project) {
        return $scope.allAvailableItems.push({
          fullObject: project,
          title: "[Projet] " + project.title,
          type: 'project'
        });
      });
    });
    MakerScienceResourceLight.getList().then(function(resourceResults) {
      return angular.forEach(resourceResults, function(resource) {
        return $scope.allAvailableItems.push({
          fullObject: resource,
          title: "[Expérience] " + resource.title,
          type: 'resource'
        });
      });
    });
    $scope.linkedItems = [];
    $scope.delLinkedItem = function(item) {
      var itemIndex;
      itemIndex = $scope.linkedItems.indexOf(item);
      return $scope.linkedItems.pop(itemIndex);
    };
    $scope.addLinkedItem = function(newLinkedItem) {
      var item;
      item = newLinkedItem.originalObject;
      if (newLinkedItem && $scope.linkedItems.indexOf(item) < 0) {
        $scope.linkedItems.push(item);
        $scope.newLinkedItem = null;
        return $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea');
      }
    };
    return $scope.saveMakersciencePost = function(newPost, parent, authorProfile) {
      return $scope.savePost(newPost, parent, authorProfile).then(function(newPost) {
        var makerSciencePost;
        makerSciencePost = {
          parent: newPost.resource_uri,
          post_type: newPost.type || 'message',
          linked_projects: newPost.linked_projects || [],
          linked_resources: []
        };
        angular.forEach($scope.questionTags, function(tag) {
          return TaggedItem.one().get({
            content_type: 'post',
            object_id: newPost.id,
            tag__slug: tag.text
          }).then(function(taggedItemResults) {
            var taggedItem;
            if (taggedItemResults.objects.length === 1) {
              taggedItem = taggedItemResults.objects[0];
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItem.id);
            }
          });
        });
        angular.forEach($scope.linkedItems, function(item) {
          return makerSciencePost["linked_" + item.type + "s"].push(item.fullObject.resource_uri);
        });
        return MakerSciencePost.post(makerSciencePost).then(function(newMakerSciencePostResult) {
          var mentions;
          mentions = newMakerSciencePostResult.parent.text.match(/\B@[a-z0-9_-]+/gi);
          angular.forEach(mentions, function(mention) {
            var profileSlug;
            profileSlug = mention.substr(1);
            return MakerScienceProfile.one().get({
              slug: profileSlug
            }).then(function(makerScienceProfileResults) {
              if (makerScienceProfileResults.objects.length === 1) {
                return ObjectProfileLink.one().customPOST({
                  profile_id: $scope.currentMakerScienceProfile.parent.id,
                  level: 41,
                  detail: profileSlug,
                  isValidated: true
                }, 'makersciencepost/' + newMakerSciencePostResult.id);
              }
            });
          });
          return newMakerSciencePostResult;
        });
      });
    };
  });

  module.controller("MakerScienceForumCtrl", function($scope, $state, $controller, $filter, MakerSciencePostLight, MakerScienceProfile, DataSharing, ObjectProfileLink, TaggedItem, CurrentMakerScienceProfileService) {
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {
      $scope: $scope
    }));
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    angular.extend(this, $controller('PostCtrl', {
      $scope: $scope
    }));
    $scope.newPost = {
      title: '',
      text: '',
      type: 'message'
    };
    $scope.params["limit"] = $scope.limit = 6;
    $scope.bestContributors = [];
    ObjectProfileLink.one().customGET('post/best', {
      level: [30, 31, 32]
    }).then(function(profileResults) {
      return angular.forEach(profileResults.objects, function(profile) {
        return MakerScienceProfile.one().get({
          parent__id: profile.id
        }).then(function(makerScienceProfileResults) {
          return $scope.bestContributors.push(makerScienceProfileResults.objects[0]);
        });
      });
    });
    $scope.refreshList = function() {
      return MakerSciencePostLight.one().customGETLIST('search', $scope.params).then(function(makerSciencePostResults) {
        var meta;
        meta = makerSciencePostResults.metadata;
        $scope.totalItems = meta.total_count;
        $scope.limit = meta.limit;
        $scope.threads = makerSciencePostResults;
        return angular.forEach($scope.threads, function(thread) {
          $scope.getPostAuthor(thread.parent_id).then(function(author) {
            return thread.author = author;
          });
          return $scope.getContributors(thread.parent_id).then(function(contributors) {
            return thread.contributors = contributors;
          });
        });
      });
    };
    $scope.initMakerScienceAbstractListCtrl();
    $scope.fetchRecentPosts = function() {
      $scope.params['ordering'] = '-updated_on';
      return $scope.refreshList();
    };
    $scope.fetchTopPosts = function() {
      $scope.params['ordering'] = '-answers_count';
      return $scope.refreshList();
    };
    $scope.fetchRecentPosts();
    return $scope.inlineSaveMakersciencePost = function(newPost) {
      $scope.errors = [];
      if ($scope.newPost.title === "") {
        $scope.errors.push("title");
      }
      if (String($scope.newPost.text).replace(/<[^>]+>/gm, '') === "") {
        $scope.errors.push("text");
      }
      if ($scope.errors.length === 0) {
        return $scope.saveMakersciencePost(newPost, null, $scope.currentMakerScienceProfile.parent).then(function(newMakerSciencePostResult) {
          $scope.refreshList();
          $scope.showCreateButton = false;
          return $scope.newPost = {
            title: '',
            text: '',
            type: 'message'
          };
        });
      }
    };
  });

  module.controller("MakerSciencePostCtrl", function($scope, $state, $stateParams, $controller, $filter, MakerSciencePost, MakerScienceProfile, ObjectProfileLink, DataSharing) {
    var resolveMentions;
    angular.extend(this, $controller('PostCtrl', {
      $scope: $scope
    }));
    angular.extend(this, $controller('PostCreateCtrl', {
      $scope: $scope
    }));
    angular.extend(this, $controller('CommunityCtrl', {
      $scope: $scope
    }));
    resolveMentions = function(post) {
      var mentions;
      mentions = post.text.match(/\B@[a-z0-9_-]+/gi);
      angular.forEach(mentions, function(mention) {
        var profileSlug;
        profileSlug = mention.substr(1);
        return MakerScienceProfile.one().get({
          slug: profileSlug
        }).then(function(makerScienceProfileResults) {
          var profile, profileAnchor, profileRoute;
          if (makerScienceProfileResults.objects.length === 1) {
            profile = makerScienceProfileResults.objects[0];
            profileRoute = $state.href("profile.detail", {
              slug: profile.slug
            });
            profileAnchor = "<a href='" + profileRoute + "'>" + profile.full_name + "</a>";
          } else {
            profileAnchor = mention;
          }
          return post.text = post.text.replace(mention, profileAnchor);
        });
      });
      angular.forEach(post.answers, function(answer) {
        return resolveMentions(answer);
      });
      return true;
    };
    MakerSciencePost.one().get({
      parent__slug: $stateParams.slug
    }).then(function(makerSciencePostResult) {
      if (makerSciencePostResult.objects.length === 0) {
        $state.go('404');
      }
      $scope.post = makerSciencePostResult.objects[0];
      $scope.fetchAuthors($scope.post.parent);
      $scope.fetchContributors($scope.post.parent);
      $scope.getSimilars($scope.post.parent.id);
      $scope.fetchPostLikes($scope.post.parent);
      resolveMentions($scope.post.parent);
      $scope.initCommunityCtrl('post', $scope.post.parent.id).then(function(community) {
        var alreadyHasProfileMember;
        $scope.contributors = [];
        $scope.followers = [];
        alreadyHasProfileMember = function(list, profile) {
          var value, _i, _len;
          for (_i = 0, _len = list.length; _i < _len; _i++) {
            value = list[_i];
            if (profile.id === value.profile.id) {
              return true;
            }
          }
          return false;
        };
        return angular.forEach(community, function(value, key) {
          var _ref;
          if (((_ref = value.level) === 30 || _ref === 31) && !alreadyHasProfileMember($scope.contributors, value.profile)) {
            return $scope.contributors.push(value);
          } else if (value.level === 32 && !alreadyHasProfileMember($scope.followers, value.profile)) {
            return $scope.followers.push(value);
          }
        });
      });
      return $scope.$watch('currentMakerScienceProfile', function(newValue, oldValue) {
        if (newValue !== null && newValue !== void 0) {
          $scope.fetchCurrentProfileLikes = function(post) {
            return ObjectProfileLink.one().get({
              level: 34,
              profile_id: $scope.currentMakerScienceProfile.parent.id,
              content_type: 'post',
              object_id: post.id
            }).then(function(results) {
              if (results.objects.length === 1) {
                post.currentProfileLike = results.objects[0];
              } else {
                post.currentProfileLike = null;
              }
              return angular.forEach(post.answers, function(answer) {
                return $scope.fetchCurrentProfileLikes(answer);
              });
            });
          };
          $scope.fetchCurrentProfileLikes($scope.post.parent);
          $scope.likePost = function(post) {
            return ObjectProfileLink.one().customPOST({
              profile_id: $scope.currentMakerScienceProfile.parent.id,
              level: 34,
              detail: '',
              isValidated: true
            }, 'post/' + post.id).then(function() {
              $scope.fetchPostLikes(post);
              return $scope.fetchCurrentProfileLikes(post);
            });
          };
          return $scope.unlikePost = function(post) {
            return ObjectProfileLink.one(post.currentProfileLike.id).remove().then(function() {
              $scope.fetchPostLikes(post);
              return $scope.fetchCurrentProfileLikes(post);
            });
          };
        }
      });
    });
    return $scope.saveMakersciencePostAnswer = function(newAnswer, parent, authorProfile) {
      return $scope.savePost(newAnswer, parent, authorProfile).then(function(newAnswer) {
        var mentions;
        newAnswer.author = authorProfile;
        mentions = newAnswer.text.match(/\B@[a-z0-9_-]+/gi);
        angular.forEach(mentions, function(mention) {
          var profileSlug;
          profileSlug = mention.substr(1);
          return MakerScienceProfile.one().get({
            slug: profileSlug
          }).then(function(makerScienceProfileResults) {
            if (makerScienceProfileResults.objects.length === 1) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 41,
                detail: profileSlug,
                isValidated: true
              }, 'post/' + newAnswer.id);
            }
          });
        });
        resolveMentions(newAnswer);
        parent.answers_count++;
        return parent.answers.push(newAnswer);
      });
    };
  });

}).call(this);
