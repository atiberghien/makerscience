(function() {
  var module;

  module = angular.module("makerscience.base.controllers", ['makerscience.base.services', 'commons.accounts.controllers']);

  module.controller("MakerScienceAbstractListCtrl", function($scope, FilterService) {
    "Abstract controller that initialize some list filtering parameters and\nwatch for changes in filterParams from FilterService\nControllers using it need to implement a refreshList() method calling adequate [Object]Service";
    $scope.currentPage = 1;
    $scope.params = {};
    $scope.getParams = function() {
      $scope.params['limit'] = $scope.limit;
      if (FilterService.filterParams.query) {
        $scope.params['q'] = FilterService.filterParams.query;
      }
      if (FilterService.filterParams.tags) {
        return $scope.params['facet'] = FilterService.filterParams.tags;
      }
    };
    $scope.pageChanged = function(newPage) {
      $scope.params["offset"] = (newPage - 1) * $scope.limit;
      return $scope.refreshListGeneric();
    };
    $scope.refreshListGeneric = function() {
      $scope.getParams();
      return $scope.refreshList();
    };
    $scope.initMakerScienceAbstractListCtrl = function() {
      var param, _results;
      FilterService.filterParams.query = '';
      FilterService.filterParams.tags = [];
      _results = [];
      for (param in FilterService.filterParams) {
        _results.push($scope.$watch(function() {
          return FilterService.filterParams[param];
        }, function(newVal, oldVal) {
          if (newVal !== oldVal) {
            return $scope.refreshListGeneric();
          }
        }));
      }
      return _results;
    };
    return $scope.$on('clearFacetFilter', function() {
      return delete $scope.params['facet'];
    });
  });

  module.controller('HomepageCtrl', function($scope, $filter, $controller, MakerScienceProjectLight, MakerScienceResourceLight, MakerScienceProfileLight, MakerSciencePostLight) {
    angular.extend(this, $controller('PostCtrl', {
      $scope: $scope
    }));
    MakerScienceProjectLight.one().customGETLIST('search', {
      ordering: '-updated_on',
      limit: 3
    }).then(function(makerScienceProjectResults) {
      return $scope.projects = makerScienceProjectResults;
    });
    MakerScienceResourceLight.one().customGETLIST('search', {
      ordering: '-updated_on',
      limit: 3
    }).then(function(makerScienceResourceResults) {
      return $scope.resources = makerScienceResourceResults;
    });
    MakerScienceProjectLight.one().customGETLIST('search', {
      featured: true,
      ordering: '-updated_on',
      limit: 2
    }).then(function(makerScienceProjectResults) {
      return $scope.featuredProjects = makerScienceProjectResults;
    });
    MakerScienceResourceLight.one().customGETLIST('search', {
      featured: true,
      ordering: '-updated_on',
      limit: 2
    }).then(function(makerScienceResourceResults) {
      return $scope.featuredResources = makerScienceResourceResults;
    });
    MakerScienceProfileLight.one().customGETLIST('search', {
      ordering: '-date_joined',
      limit: 3
    }).then(function(makerScienceProfileResults) {
      return $scope.profiles = makerScienceProfileResults;
    });
    return MakerSciencePostLight.one().customGETLIST('search', {
      ordering: '-created_on',
      limit: 5
    }).then(function(makerSciencePostResults) {
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
  });

  module.controller("StaticContentCtrl", function($scope, StaticContent) {
    return $scope["static"] = StaticContent.one(1).get().$object;
  });

  module.controller("MakerScienceObjectGetter", function($scope, $q, Vote, Tag, TaggedItem, MakerScienceProject, MakerScienceResource, MakerScienceProfile, MakerSciencePost) {
    return $scope.getObject = function(objectTypeName, objectId) {
      if (objectTypeName === 'project') {
        return MakerScienceProject.one().get({
          parent__id: objectId
        }).then(function(makerScienceProjectResults) {
          if (makerScienceProjectResults.objects.length === 1) {
            return makerScienceProjectResults.objects[0];
          } else {
            return MakerScienceResource.one().get({
              parent__id: objectId
            }).then(function(makerScienceResourceResults) {
              if (makerScienceResourceResults.objects.length === 1) {
                return makerScienceResourceResults.objects[0];
              }
            });
          }
        });
      } else if (objectTypeName === 'makerscienceproject') {
        return MakerScienceProject.one(objectId).get().then(function(makerScienceProjectResult) {
          return makerScienceProjectResult;
        });
      } else if (objectTypeName === 'makerscienceresource') {
        return MakerScienceResource.one(objectId).get().then(function(makerScienceResourceResult) {
          return makerScienceResourceResult;
        });
      } else if (objectTypeName === 'makerscienceprofile') {
        return MakerScienceProfile.one().get({
          id: objectId
        }).then(function(profileResults) {
          if (profileResults.objects.length === 1) {
            return profileResults.objects[0];
          }
        });
      } else if (objectTypeName === 'profile') {
        return MakerScienceProfile.one().get({
          parent__id: objectId
        }).then(function(profileResults) {
          if (profileResults.objects.length === 1) {
            return profileResults.objects[0];
          }
        });
      } else if (objectTypeName === 'user') {
        return MakerScienceProfile.one().get({
          parent__user__id: objectId
        }).then(function(profileResults) {
          if (profileResults.objects.length === 1) {
            return profileResults.objects[0];
          }
        });
      } else if (objectTypeName === 'makersciencepost') {
        return MakerSciencePost.one(objectId).get().then(function(makerSciencePostResult) {
          return makerSciencePostResult;
        });
      } else if (objectTypeName === 'post') {
        return MakerSciencePost.one().get({
          parent__id: objectId
        }).then(function(makerSciencePostResults) {
          if (makerSciencePostResults.objects.length === 1) {
            return makerSciencePostResults.objects[0];
          }
        });
      } else if (objectTypeName === 'taggeditem') {
        return TaggedItem.one(objectId).get().then(function(taggedItemResult) {
          return taggedItemResult;
        });
      } else if (objectTypeName === 'tag') {
        return Tag.one(objectId).get().then(function(tagResult) {
          return tagResult;
        });
      } else if (objectTypeName === 'vote') {
        return Vote.one(objectId).get();
      }
      return null;
    };
  });

  module.controller("MakerScienceSearchEveryWhereCtrl", function($scope, $controller, MakerScienceProjectLight, MakerScienceResourceLight, MakerScienceProfileLight, MakerSciencePostLight) {
    $scope.globalQuery = null;
    $scope.globalProjects = [];
    $scope.globalResources = [];
    $scope.globalProfiles = [];
    $scope.globalThreads = [];
    $scope.globalSearch = function() {
      MakerScienceProfileLight.one().customGETLIST('search', {
        q: $scope.globalQuery
      }).then(function(makerScienceProfileResults) {
        return $scope.globalProfiles = makerScienceProfileResults;
      });
      MakerScienceProjectLight.one().customGETLIST('search', {
        q: $scope.globalQuery
      }).then(function(makerScienceProjectResults) {
        return $scope.globalProjects = makerScienceProjectResults;
      });
      MakerScienceResourceLight.one().customGETLIST('search', {
        q: $scope.globalQuery
      }).then(function(makerScienceResourceResults) {
        return $scope.globalResources = makerScienceResourceResults;
      });
      return MakerSciencePostLight.one().customGETLIST('search', {
        q: $scope.globalQuery
      }).then(function(makerSciencePostResults) {
        return $scope.globalThreads = makerSciencePostResults;
      });
    };
    return $scope.runAutoCompleteSearch = function() {
      if ($scope.globalQuery.length >= 3) {
        return $scope.globalSearch();
      }
    };
  });

  module.controller("MakerScienceSearchCtrl", function($scope, $controller, $parse, $stateParams, Tag, TaggedItem, ObjectProfileLink, MakerScienceProjectLight, MakerScienceResourceLight, MakerScienceProfileLight, MakerSciencePostLight) {
    angular.extend(this, $controller('PostCtrl', {
      $scope: $scope
    }));
    $scope.collapseAdvancedSearch = true;
    $scope.followedTag = null;
    $scope.runSearch = function(params) {
      var findRelatedTag;
      $scope.associatedTags = [];
      findRelatedTag = function(taggedItemResults) {
        return angular.forEach(taggedItemResults.objects, function(taggedItem) {
          if ($scope.associatedTags.indexOf(taggedItem.tag.slug) === -1) {
            return $scope.associatedTags.push(taggedItem.tag.slug);
          }
        });
      };
      MakerScienceProfileLight.one().customGETLIST('search', params).then(function(makerScienceProfileResults) {
        angular.forEach(makerScienceProfileResults, function(profile) {
          return TaggedItem.one().customGET("makerscienceprofile/" + profile.id).then(findRelatedTag);
        });
        return $scope.profiles = makerScienceProfileResults;
      });
      MakerScienceProjectLight.one().customGETLIST('search', params).then(function(makerScienceProjectResults) {
        angular.forEach(makerScienceProjectResults, function(project) {
          return TaggedItem.one().customGET("makerscienceproject/" + project.id).then(findRelatedTag);
        });
        return $scope.projects = makerScienceProjectResults;
      });
      MakerScienceResourceLight.one().customGETLIST('search', params).then(function(makerScienceResourceResults) {
        angular.forEach(makerScienceResourceResults, function(resource) {
          return TaggedItem.one().customGET("makerscienceresource/" + resource.id).then(findRelatedTag);
        });
        return $scope.resources = makerScienceResourceResults;
      });
      MakerSciencePostLight.one().customGETLIST('search', params).then(function(makerSciencePostResults) {
        angular.forEach(makerSciencePostResults, function(post) {
          return TaggedItem.one().customGET("makersciencepost/" + post.id).then(findRelatedTag);
        });
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
      return TaggedItem.getList({
        tag__slug: params["facet"]
      }).then(function(taggedItemResults) {
        $scope.taggerProfiles = [];
        return angular.forEach(taggedItemResults, function(taggedItem) {
          return ObjectProfileLink.one().customGET('taggeditem/' + taggedItem.id).then(function(objectProfileLinkResults) {
            var genericProfileId;
            if (objectProfileLinkResults.objects.length > 0) {
              genericProfileId = objectProfileLinkResults.objects[0].profile.id;
              return MakerScienceProfileLight.one().get({
                'parent__id': genericProfileId
              }).then(function(makerScienceProfileResults) {
                var tagger;
                if (makerScienceProfileResults.objects.length > 0) {
                  tagger = makerScienceProfileResults.objects[0];
                  tagger.taggingDate = objectProfileLinkResults.objects[0].created_on;
                  return $scope.taggerProfiles.push(tagger);
                }
              });
            }
          });
        });
      });
    };
    if ($stateParams.hasOwnProperty('q')) {
      $scope.query = $stateParams.q;
      $scope.runSearch({
        q: $stateParams.q
      });
    }
    if ($stateParams.hasOwnProperty('slug')) {
      Tag.one().get({
        slug: $stateParams.slug
      }).then(function(tagResults) {
        var checkFollowedTag;
        if (tagResults.objects.length === 1) {
          $scope.tag = tagResults.objects[0];
          $scope.runSearch({
            facet: $stateParams.slug
          });
          checkFollowedTag = function() {
            return ObjectProfileLink.one().get({
              profile_id: $scope.currentMakerScienceProfile.parent.id,
              level: 51,
              content_type: 'tag',
              object_id: $scope.tag.id
            }).then(function(results) {
              if (results.objects.length === 1) {
                return $scope.followedTag = results.objects[0];
              } else {
                return $scope.followedTag = null;
              }
            });
          };
          if ($scope.currentMakerScienceProfile && $scope.followedTag === null) {
            return checkFollowedTag();
          } else {
            return $scope.$watch('currentMakerScienceProfile', function(newValue, oldValue) {
              if (newValue !== null && newValue !== void 0 && $scope.followedTag === null) {
                console.log("ET LA ?");
                return checkFollowedTag();
              }
            });
          }
        }
      });
    }
    $scope.search = {
      advanced: true,
      searchIn: 'all',
      allWords: [],
      exactExpressions: []
    };
    $scope.runAdvancedSearch = function(search) {
      $scope.runSearch(search);
      return $scope.search = {
        advanced: true,
        searchIn: 'all',
        allWords: "",
        exactExpressions: ""
      };
    };
    $scope.followTag = function(tag) {
      return ObjectProfileLink.one().customPOST({
        profile_id: $scope.currentMakerScienceProfile.parent.id,
        level: 51,
        detail: '',
        isValidated: true
      }, 'tag/' + $scope.tag.id).then(function(result) {
        return $scope.followedTag = result;
      });
    };
    return $scope.unfollowTag = function() {
      return ObjectProfileLink.one($scope.followedTag.id).remove().then(function() {
        return $scope.followedTag = null;
      });
    };
  });

  module.controller("FilterCtrl", function($scope, $stateParams, Tag, FilterService) {
    $scope.tags_filter = [];
    $scope.query_filter = '';
    $scope.refreshFilter = function() {
      "Update FilterService data";
      var tag, tags_list, _i, _len, _ref;
      tags_list = [];
      _ref = $scope.tags_filter;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tag = _ref[_i];
        tags_list.push(tag.text);
      }
      FilterService.filterParams.tags = tags_list;
      return FilterService.filterParams.query = $scope.query_filter;
    };
    $scope.addToTagsFilter = function(aTag) {
      var simpleTag;
      simpleTag = {
        text: aTag.name
      };
      if ($scope.tags_filter.indexOf(simpleTag) === -1) {
        $scope.tags_filter.push(simpleTag);
      }
      return $scope.refreshFilter();
    };
    return $scope.$on('clearFacetFilter', function() {
      $scope.tags_filter = [];
      return FilterService.filterParams.tags = [];
    });
  });

  module.controller("NotificationCtrl", function($scope, $rootScope, $controller, $timeout, $interval, $filter, ObjectProfileLink, Notification) {
    $scope.updateNotifications = function(markAllAsRead) {
      if ($rootScope.authVars.isAuthenticated && $scope.currentMakerScienceProfile !== null && $scope.currentMakerScienceProfile !== void 0) {
        return Notification.getList({
          recipient_id: $scope.currentMakerScienceProfile.parent.user.id
        }).then(function(notificationResults) {
          $scope.notifications = notificationResults;
          $scope.lastNotifications = $filter('limitTo')(notificationResults, 8);
          $scope.computeUnreadNotificationCounter();
          if (markAllAsRead === true) {
            return angular.forEach($scope.notifications, $scope.markAsRead);
          }
        });
      }
    };
    $scope.computeUnreadNotificationCounter = function() {
      $scope.displayedUnreadNotifications = $filter('filter')($scope.lastNotifications, {
        unread: true
      });
      return $scope.unreadNotificationCounter = $filter('filter')($scope.notifications, {
        unread: true
      }).length;
    };
    $scope.markAllAsRead = function() {
      return $timeout(function() {
        angular.forEach($filter('filter')($scope.notifications, {
          unread: true
        }), $scope.markAsRead);
        return $scope.computeUnreadNotificationCounter();
      }, 2000);
    };
    $scope.markAsRead = function(notif) {
      Notification.one(notif.id).patch({
        unread: false
      });
      return notif.unread = false;
    };
    return $scope.$watch('currentMakerScienceProfile', function(newValue, oldValue) {
      if (newValue !== oldValue) {
        $scope.updateNotifications(false);
        return $interval(function() {
          return $scope.updateNotifications(false);
        }, 30000);
      }
    });
  });

  module.controller('ReportAbuseFormInstanceCtrl', function($scope, $modalInstance, $timeout, User, vcRecaptchaService, currentLocation) {
    $scope.success = false;
    $scope.setResponse = function(response) {
      return $scope.response = response;
    };
    $scope.setWidgetId = function(widgetId) {
      return $scope.widgetId = widgetId;
    };
    $scope.cbExpiration = function() {
      return $scope.response = null;
    };
    return $scope.sendMessage = function(message) {
      if ($scope.response) {
        message.recaptcha_response = $scope.response;
        message.subject = 'Un abus a été signalé sur la page ' + currentLocation;
        return User.one().customPOST(message, 'report/abuse', {}).then(function(response) {
          $scope.success = true;
          return $timeout($modalInstance.close, 3000);
        }, function(response) {
          return console.log("RECAPTCHA ERROR", response);
        });
      }
    };
  });

  module.controller('BasicModalInstanceCtrl', function($scope, $modalInstance, content) {
    $scope.content = content;
    $scope.ok = function() {
      return $modalInstance.close();
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

}).call(this);
