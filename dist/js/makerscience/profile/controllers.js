(function() {
  var module;

  module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'makerscience.base.services', 'commons.tags.services', 'commons.accounts.services', 'makerscience.base.controllers']);

  module.controller("MakerScienceProfileListCtrl", function($scope, $controller, MakerScienceProfileLight, MakerScienceProfileTaggedItem) {
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {
      $scope: $scope
    }));
    $scope.params["limit"] = $scope.limit = 6;
    $scope.refreshList = function() {
      return MakerScienceProfileLight.one().customGETLIST('search', $scope.params).then(function(makerScienceProfileResults) {
        var meta;
        meta = makerScienceProfileResults.metadata;
        $scope.totalItems = meta.total_count;
        $scope.limit = meta.limit;
        return $scope.profiles = makerScienceProfileResults;
      });
    };
    $scope.initMakerScienceAbstractListCtrl();
    $scope.fetchRecentProfiles = function() {
      $scope.$broadcast('clearFacetFilter');
      $scope.params['ordering'] = '-date_joined';
      return $scope.refreshList();
    };
    $scope.fetchTopProfiles = function() {
      $scope.$broadcast('clearFacetFilter');
      $scope.params['ordering'] = '-activity_score';
      return $scope.refreshList();
    };
    $scope.fetchRandomProfiles = function() {
      $scope.$broadcast('clearFacetFilter');
      $scope.params['ordering'] = '';
      return $scope.refreshList().then(function() {
        var nbElmt, rand, tmp, _results;
        nbElmt = $scope.profiles.length;
        _results = [];
        while (nbElmt) {
          rand = Math.floor(Math.random() * nbElmt--);
          tmp = $scope.profiles[nbElmt];
          $scope.profiles[nbElmt] = $scope.profiles[rand];
          _results.push($scope.profiles[rand] = tmp);
        }
        return _results;
      });
    };
    $scope.availableInterestTags = [];
    $scope.availableSkillTags = [];
    return MakerScienceProfileTaggedItem.getList({
      distinct: 'True'
    }).then(function(taggedItemResults) {
      return angular.forEach(taggedItemResults, function(taggedItem) {
        switch (taggedItem.tag_type) {
          case 'sk':
            return $scope.availableSkillTags.push(taggedItem.tag);
          case 'in':
            return $scope.availableInterestTags.push(taggedItem.tag);
        }
      });
    });
  });

  module.controller('AvatarUploaderInstanceCtrl', function($scope, $modalInstance, $http, FileUploader) {
    var dataURItoBlob, uploader;
    this.$http = $http;
    uploader = $scope.uploader = new FileUploader({
      url: config.media_uri + $scope.currentMakerScienceProfile.resource_uri + '/avatar/upload',
      queueLimit: 2,
      headers: {
        Authorization: this.$http.defaults.headers.common.Authorization
      }
    });
    uploader.filters.push({
      name: 'imageFilter',
      fn: function(item, options) {
        var type;
        type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|';
        return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
      }
    });
    uploader.onAfterAddingFile = function(item) {
      var reader;
      if (uploader.queue.length > 1) {
        uploader.removeFromQueue(0);
      }
      item.croppedImage = '';
      reader = new FileReader();
      reader.onload = function(event) {
        return $scope.$apply(function() {
          return item.image = event.target.result;
        });
      };
      return reader.readAsDataURL(item._file);
    };
    uploader.onBeforeUploadItem = function(item) {
      var blob;
      blob = dataURItoBlob(item.croppedImage);
      return item._file = blob;
    };
    uploader.onSuccessItem = function(item, response, status, headers) {
      return $modalInstance.close(response.avatar);
    };
    return dataURItoBlob = function(dataURI) {
      var array, binary, i, mimeString, _i, _ref;
      binary = atob(dataURI.split(',')[1]);
      mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
      array = [];
      for (i = _i = 0, _ref = binary.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        array.push(binary.charCodeAt(i));
      }
      return new Blob([new Uint8Array(array)], {
        type: mimeString
      });
    };
  });

  module.controller('BioInstanceCtrl', function($scope, $modalInstance, MakerScienceProfile, editable, profile) {
    $scope.editable = editable;
    $scope.profile = profile;
    $scope.ok = function() {
      if (editable) {
        MakerScienceProfile.one($scope.profile.slug).patch({
          bio: $scope.profile.bio
        });
      }
      return $modalInstance.close();
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

  module.controller('SocialsEditInstanceCtrl', function($scope, $modalInstance, MakerScienceProfile, socials, profile) {
    $scope.profile = profile;
    $scope.socials = socials;
    $scope.ok = function() {
      angular.forEach($scope.socials, function(value, key) {
        if (value) {
          if (value.startsWith("http://") === false || value.startsWith("https://") !== false) {
            value = "http://" + value;
          }
          return $scope.profile[key] = value;
        }
      });
      return MakerScienceProfile.one($scope.profile.slug).patch($scope.socials).then(function() {
        return $modalInstance.close();
      });
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

  module.controller("MakerScienceProfileCtrl", function($scope, $rootScope, $controller, $stateParams, $state, $modal, TaggedItemService, MakerScienceProfile, MakerScienceProfileLight, MakerScienceProjectLight, MakerScienceResourceLight, MakerSciencePost, MakerSciencePostLight, MakerScienceProfileTaggedItem, TaggedItem, Tag, Post, ObjectProfileLink, PostalAddress) {
    angular.extend(this, $controller('MakerScienceObjectGetter', {
      $scope: $scope
    }));
    angular.extend(this, $controller('PostCtrl', {
      $scope: $scope
    }));
    $scope.openTagPopup = function(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) {
      return TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback);
    };
    return MakerScienceProfile.one($stateParams.slug).get().then(function(makerscienceProfileResult) {
      $scope.profile = makerscienceProfileResult;
      $scope.editable = $scope.profile.can_edit;
      $rootScope.$broadcast('profile-loaded', $scope.profile);
      $rootScope.$emit('profile-loaded', $scope.profile);
      $scope.preparedInterestTags = [];
      $scope.preparedSkillTags = [];
      $scope.member_projects = [];
      $scope.member_resources = [];
      $scope.fan_projects = [];
      $scope.fan_resources = [];
      $scope.authored_post = [];
      $scope.contributed_post = [];
      $scope.liked_post = [];
      $scope.followed_post = [];
      $scope.friends = [];
      $scope.socials = {
        facebook: $scope.profile.facebook,
        linkedin: $scope.profile.linkedin,
        twitter: $scope.profile.twitter,
        contact_email: $scope.profile.contact_email,
        website: $scope.profile.website
      };
      $scope.similars = [];
      $scope.favoriteTags = {};
      $scope.followedTags = [];
      $scope.infiniteScrollActivitiesLimit = 3;
      $scope.infiniteScrollActivitiesTotalCount = null;
      $scope.infiniteScrollActivitiesCall = 0;
      $scope.infiniteScrollActivitiesCounter = 1;
      $scope.addMoreActivities = function() {
        $scope.infiniteScrollActivitiesCall++;
        if ($scope.infiniteScrollActivitiesTotalCount && $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter > $scope.infiniteScrollActivitiesTotalCount) {
          return;
        }
        if ($scope.infiniteScrollActivitiesCall === $scope.infiniteScrollActivitiesCounter) {
          return MakerScienceProfile.one($scope.profile.slug).customGET('activities', {
            limit: $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter
          }).then(function(activityResults) {
            $scope.infiniteScrollActivitiesTotalCount = activityResults.metadata.total_count;
            $scope.infiniteScrollActivities = activityResults.objects;
            return $scope.infiniteScrollActivitiesCounter++;
          });
        } else {
          return $scope.infiniteScrollActivitiesCall--;
        }
      };
      $scope.addMoreActivities();
      ObjectProfileLink.getList({
        profile__id: $scope.profile.parent.id,
        isValidated: true
      }).then(function(objectProfileLinkResults) {
        return angular.forEach(objectProfileLinkResults, function(objectProfileLink) {
          if (objectProfileLink.content_type === 'makerscienceproject') {
            return MakerScienceProjectLight.one().get({
              id: objectProfileLink.object_id
            }).then(function(makerscienceProjectResults) {
              if (makerscienceProjectResults.objects.length === 1) {
                if (objectProfileLink.level === 0) {
                  return $scope.member_projects.push(makerscienceProjectResults.objects[0]);
                } else if (objectProfileLink.level === 2) {
                  return $scope.fan_projects.push(makerscienceProjectResults.objects[0]);
                }
              }
            });
          } else if (objectProfileLink.content_type === 'makerscienceresource') {
            return MakerScienceResourceLight.one().get({
              id: objectProfileLink.object_id
            }).then(function(makerscienceResourceResults) {
              if (makerscienceResourceResults.objects.length === 1) {
                if (objectProfileLink.level === 10) {
                  return $scope.member_resources.push(makerscienceResourceResults.objects[0]);
                } else if (objectProfileLink.level === 12) {
                  return $scope.fan_resources.push(makerscienceResourceResults.objects[0]);
                }
              }
            });
          } else if (objectProfileLink.content_type === 'makerscienceprofile' && objectProfileLink.level === 40) {
            return MakerScienceProfileLight.one().get({
              id: objectProfileLink.object_id
            }).then(function(profileResults) {
              if (profileResults.objects.length === 1) {
                return $scope.friends.push(profileResults.objects[0]);
              }
            });
          } else if (objectProfileLink.content_type === 'post') {
            return MakerSciencePostLight.one().get({
              parent_id: objectProfileLink.object_id
            }).then(function(makersciencePostResults) {
              var post;
              if (makersciencePostResults.objects.length === 1) {
                post = makersciencePostResults.objects[0];
                $scope.getPostAuthor(post.parent_id).then(function(author) {
                  return post.author = author;
                });
                $scope.getContributors(post.parent_id).then(function(contributors) {
                  return post.contributors = contributors;
                });
                if (objectProfileLink.level === 30 && $scope.authored_post.indexOf(post) === -1) {
                  return $scope.authored_post.push(post);
                } else if (objectProfileLink.level === 33 && $scope.liked_post.indexOf(post) === -1) {
                  return $scope.liked_post.push(post);
                } else if (objectProfileLink.level === 32 && $scope.followed_post.indexOf(post) === -1) {
                  return $scope.followed_post.push(post);
                }
              } else {
                if (objectProfileLink.level === 31) {
                  return Post.one(objectProfileLink.object_id).customGET("root").then(function(root) {
                    return MakerSciencePostLight.one().get({
                      parent_id: root.id
                    }).then(function(makersciencePostResults) {
                      post = makersciencePostResults.objects[0];
                      return $scope.getPostAuthor(post.parent_id).then(function(author) {
                        post.author = author;
                        if ($scope.contributed_post.indexOf(post) === -1 && post.author.id !== $scope.profile.parent.id) {
                          return $scope.getContributors(post.parent_id).then(function(contributors) {
                            post.contributors = contributors;
                            return $scope.contributed_post.push(post);
                          });
                        }
                      });
                    });
                  });
                }
              }
            });
          } else if (objectProfileLink.content_type === 'taggeditem' && objectProfileLink.level === 50) {
            return TaggedItem.one(objectProfileLink.object_id).get().then(function(taggedItemResult) {
              var slug;
              slug = taggedItemResult.tag.slug;
              if ($scope.favoriteTags.hasOwnProperty(slug)) {
                return $scope.favoriteTags[slug]++;
              } else {
                return $scope.favoriteTags[slug] = 1;
              }
            });
          } else if (objectProfileLink.content_type === 'tag' && objectProfileLink.level === 51) {
            return Tag.one(objectProfileLink.object_id).get().then(function(tagResult) {
              return $scope.followedTags.push(tagResult);
            });
          }
        });
      });
      TaggedItem.one().customGET("makerscienceprofile/" + $scope.profile.id + "/similars").then(function(similarResults) {
        return angular.forEach(similarResults, function(similar) {
          if (similar.type === 'makerscienceprofile') {
            return MakerScienceProfileLight.one().get({
              id: similar.id
            }).then(function(makersciencePostResults) {
              return $scope.similars.push(makersciencePostResults.objects[0]);
            });
          }
        });
      });
      angular.forEach($scope.profile.tags, function(taggedItem) {
        switch (taggedItem.tag_type) {
          case "in":
            return $scope.preparedInterestTags.push({
              text: taggedItem.tag.name,
              slug: taggedItem.tag.slug,
              taggedItemId: taggedItem.id
            });
          case "sk":
            return $scope.preparedSkillTags.push({
              text: taggedItem.tag.name,
              slug: taggedItem.tag.slug,
              taggedItemId: taggedItem.id
            });
        }
      });
      $scope.showAvatarPopup = function() {
        var modalInstance;
        modalInstance = $modal.open({
          templateUrl: '/views/profile/block/avatar_uploader.html',
          controller: 'AvatarUploaderInstanceCtrl'
        });
        return modalInstance.result.then(function(avatar) {
          $scope.profile.parent.avatar = avatar;
          return $scope.currentMakerScienceProfile.parent.avatar = avatar;
        });
      };
      $scope.openBioPopup = function(editable) {
        var modalInstance;
        return modalInstance = $modal.open({
          templateUrl: '/views/profile/block/bioModal.html',
          controller: 'BioInstanceCtrl',
          resolve: {
            editable: function() {
              return editable;
            },
            profile: function() {
              return $scope.profile;
            }
          }
        });
      };
      $scope.openSocialsEditPopup = function() {
        var modalInstance;
        return modalInstance = $modal.open({
          templateUrl: 'views/profile/block/socialsEditPopup.html',
          controller: 'SocialsEditInstanceCtrl',
          resolve: {
            profile: function() {
              return $scope.profile;
            },
            socials: function() {
              return $scope.socials;
            }
          }
        });
      };
      $scope.addTagToProfile = function(tag_type, tag) {
        return MakerScienceProfileTaggedItem.one().customPOST({
          tag: tag.text
        }, "makerscienceprofile/" + $scope.profile.id + "/" + tag_type, {}).then(function(taggedItemResult) {
          ObjectProfileLink.one().customPOST({
            profile_id: $scope.currentMakerScienceProfile.parent.id,
            level: 50,
            detail: '',
            isValidated: true
          }, 'taggeditem/' + taggedItemResult.id);
          if (tag_type === 'in') {
            ObjectProfileLink.one().customPOST({
              profile_id: $scope.currentMakerScienceProfile.parent.id,
              level: 51,
              detail: '',
              isValidated: true
            }, 'tag/' + taggedItemResult.tag.id);
          }
          return tag.taggedItemId = taggedItemResult.id;
        });
      };
      $scope.removeTagFromProfile = function(tag) {
        return MakerScienceProfileTaggedItem.one(tag.taggedItemId).remove();
      };
      return $scope.updateMakerScienceProfile = function(resourceName, resourceId, fieldName, data) {
        var putData;
        putData = {};
        putData[fieldName] = data;
        console.log(resourceName, resourceId, fieldName, data);
        switch (resourceName) {
          case 'MakerScienceProfile':
            return MakerScienceProfile.one(resourceId).patch(putData);
          case 'PostalAddress':
            return PostalAddress.one(resourceId).patch(putData);
        }
      };
    }, function(response) {
      if (response.status === 404) {
        return MakerScienceProfile.one().get({
          parent__id: $stateParams.slug
        }).then(function(makerscienceProfileResults) {
          if (makerscienceProfileResults.objects.length === 1) {
            return $state.go('profile.detail', {
              slug: makerscienceProfileResults.objects[0].slug
            });
          } else {
            return $state.go('404');
          }
        }, function() {
          return $state.go('profile.list');
        });
      }
    });
  });

  module.controller("MakerScienceResetPasswordCtrl", function($scope, $state, $stateParams, $timeout, MakerScienceProfile) {
    $scope.passwordResetFail = false;
    $scope.passwordResetSuccess = false;
    $scope.notMatchingEmailError = false;
    $scope.passwordReset = '';
    $scope.passwordReset2 = '';
    if ($stateParams.hasOwnProperty('hash') && $stateParams.hasOwnProperty('email')) {
      $scope.email = $stateParams.email;
      $scope.finalizeResetPassword = function() {
        $scope.passwordResetFail = false;
        $scope.passwordResetSuccess = false;
        if ($scope.passwordReset !== null && $scope.passwordReset !== $scope.passwordReset2) {
          $scope.passwordResetFail = true;
        } else {
          return MakerScienceProfile.one().customGET('reset/password', {
            email: $scope.email,
            hash: $stateParams.hash,
            password: $scope.passwordReset
          }).then(function(result) {
            if (result.success) {
              $scope.passwordResetSuccess = true;
              return $timeout(function() {
                return $state.go('home');
              }, 5000);
            } else {
              return $scope.notMatchingEmailError = true;
            }
          });
        }
      };
    }
    return $scope.resetPassword = function(email) {
      $scope.unknownProfileError = false;
      $scope.passwordResetEmailSent = false;
      return MakerScienceProfile.one().customGET('reset/password', {
        email: email
      }).then(function(result) {
        if (result.success) {
          return $scope.passwordResetEmailSent = true;
        } else {
          return $scope.unknownProfileError = true;
        }
      });
    };
  });

  module.controller("MakerScienceProfileDashboardCtrl", function($scope, $rootScope, $controller, $stateParams, $state, MakerScienceProfile, User, Notification, ObjectProfileLink) {
    return MakerScienceProfile.one($stateParams.slug).get().then(function(makerscienceProfileResult) {
      $scope.profile = makerscienceProfileResult;
      if (!$scope.authVars.isAuthenticated || $scope.currentMakerScienceProfile === void 0 || $scope.currentMakerScienceProfile.id !== $scope.profile.id) {
        $state.go('profile.detail', {
          slug: $stateParams.slug
        });
      }
      $scope.user = {
        first_name: $scope.profile.parent.user.first_name,
        last_name: $scope.profile.parent.user.last_name,
        email: $scope.profile.parent.user.email,
        notifFreq: $scope.profile.notif_subcription_freq,
        authorizedContact: $scope.profile.authorized_contact,
        passwordReset: '',
        passwordReset2: ''
      };
      $scope.passwordError = false;
      $scope.passwordResetSuccess = false;
      $scope.infiniteScrollNotificationsLimit = 6;
      $scope.infiniteScrollNotificationsTotalCount = null;
      $scope.infiniteScrollNotificationsCall = 0;
      $scope.infiniteScrollNotificationsCounter = 1;
      $scope.addMoreNotifications = function() {
        $scope.infiniteScrollNotificationsCall++;
        if ($scope.infiniteScrollNotificationsTotalCount && $scope.infiniteScrollNotificationsLimit * $scope.infiniteScrollNotificationsCounter > $scope.infiniteScrollNotificationsTotalCount) {
          return;
        }
        if ($scope.infiniteScrollNotificationsCall === $scope.infiniteScrollNotificationsCounter) {
          return Notification.getList({
            recipient_id: $scope.profile.parent.user.id,
            limit: $scope.infiniteScrollNotificationsLimit * $scope.infiniteScrollNotificationsCounter
          }).then(function(notificationResults) {
            $scope.infiniteScrollNotificationsTotalCount = notificationResults.metadata.total_count;
            $scope.infiniteScrollNotifications = notificationResults;
            return $scope.infiniteScrollNotificationsCounter++;
          });
        } else {
          return $scope.infiniteScrollNotificationsCall--;
        }
      };
      $scope.infiniteScrollActivitiesLimit = 6;
      $scope.infiniteScrollActivitiesTotalCount = null;
      $scope.infiniteScrollActivitiesCall = 0;
      $scope.infiniteScrollActivitiesCounter = 1;
      $scope.addMoreActivities = function() {
        $scope.infiniteScrollActivitiesCall++;
        if ($scope.infiniteScrollActivitiesTotalCount && $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter > $scope.infiniteScrollActivitiesTotalCount) {
          return;
        }
        if ($scope.infiniteScrollActivitiesCall === $scope.infiniteScrollActivitiesCounter) {
          return MakerScienceProfile.one($scope.profile.slug).customGET('contacts/activities', {
            limit: $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter
          }).then(function(activityResults) {
            $scope.infiniteScrollActivitiesTotalCount = activityResults.metadata.total_count;
            $scope.infiniteScrollActivities = activityResults.objects;
            return $scope.infiniteScrollActivitiesCounter++;
          });
        } else {
          return $scope.infiniteScrollActivitiesCall--;
        }
      };
      $scope.addMoreNotifications();
      $scope.addMoreActivities();
      $scope.deleteProfile = function() {
        MakerScienceProfile.one($scope.profile.slug).remove();
        $rootScope.loginService.logout();
        return $state.go("home", {});
      };
      $scope.updateMakerScienceUserInfo = function() {
        angular.forEach($scope.user, function(value, key) {
          var data;
          data = {};
          data[key] = value;
          return User.one($scope.profile.parent.user.username).patch(data);
        });
        return $scope.profile.full_name = $scope.user.first_name + " " + $scope.user.last_name;
      };
      $scope.updateNotifFrequency = function(frequency) {
        MakerScienceProfile.one($scope.profile.slug).patch({
          notif_subcription_freq: frequency
        });
        return $scope.user.notifFreq = frequency;
      };
      $scope.updateAuthorizedContact = function(authorizedContact) {
        MakerScienceProfile.one($scope.profile.slug).patch({
          authorized_contact: authorizedContact
        });
        return $scope.user.authorizedContact = authorizedContact;
      };
      return $scope.changeMakerScienceProfilePassword = function() {
        $scope.passwordResetFail = false;
        $scope.passwordResetSuccess = false;
        if ($scope.user.passwordReset !== null && $scope.user.passwordReset !== $scope.user.passwordReset2) {
          $scope.passwordResetFail = true;
        } else {
          return MakerScienceProfile.one($scope.profile.slug).customPOST({
            password: $scope.user.passwordReset
          }, 'change/password', {}).then(function(result) {
            return $scope.passwordResetsuccess = true;
          });
        }
      };
    }, function(response) {
      if (response.status === 404) {
        return MakerScienceProfile.one().get({
          parent__id: $stateParams.slug
        }).then(function(makerscienceProfileResults) {
          if (makerscienceProfileResults.objects.length === 1) {
            return $state.go('profile.dashboard', {
              slug: makerscienceProfileResults.objects[0].slug
            });
          } else {
            return $state.go('404');
          }
        });
      }
    });
  });

  module.controller("FriendshipCtrl", function($scope, $rootScope, $modal, ObjectProfileLink, MakerScienceProfile) {
    $scope.addFriend = function(friendProfileID) {
      ObjectProfileLink.one().customPOST({
        profile_id: $scope.currentMakerScienceProfile.parent.id,
        level: 40,
        detail: "Ami",
        isValidated: true
      }, 'makerscienceprofile/' + friendProfileID);
      return $scope.isFriend = true;
    };
    $scope.removeFriend = function(friendProfileID) {
      return $scope.checkFriend(friendProfileID).then(function(currentLink) {
        ObjectProfileLink.one(currentLink.id).remove();
        return $scope.isFriend = false;
      });
    };
    $scope.checkFriend = function(makerscienceProfileID) {
      if ($scope.currentMakerScienceProfile && makerscienceProfileID) {
        return ObjectProfileLink.one().customGET('makerscienceprofile/' + makerscienceProfileID, {
          profile__id: $scope.currentMakerScienceProfile.parent.id,
          level: 40
        }).then(function(objectProfileLinkResults) {
          if (objectProfileLinkResults.objects.length === 1) {
            $scope.isFriend = true;
            return objectProfileLinkResults.objects[0];
          }
        });
      }
    };
    $scope.checkFollowing = function(profileID) {
      if ($scope.currentMakerScienceProfile && profileID) {
        return MakerScienceProfile.one().get({
          parent__id: profileID
        }).then(function(makerscienceProfileResults) {
          if (makerscienceProfileResults.objects.length === 1) {
            $scope.viewedMakerscienceProfile = makerscienceProfileResults.objects[0];
            return ObjectProfileLink.one().customGET('makerscienceprofile/' + $scope.currentMakerScienceProfile.id, {
              profile__id: profileID,
              level: 40
            }).then(function(objectProfileLinkResults) {
              if (objectProfileLinkResults.objects.length === 1) {
                $scope.isFollowed = true;
                return objectProfileLinkResults.objects[0];
              }
            });
          }
        });
      }
    };
    $scope.showContactPopup = function(profile) {
      if (typeof profile === 'number') {
        return MakerScienceProfile.one().get({
          parent__id: profile
        }).then(function(makerscienceProfileResults) {
          if (makerscienceProfileResults.objects.length === 1) {
            return $modal.open({
              templateUrl: '/views/profile/block/contact.html',
              controller: 'ContactFormInstanceCtrl',
              resolve: {
                profile: function() {
                  return makerscienceProfileResults.objects[0];
                }
              }
            });
          }
        });
      } else {
        return $modal.open({
          templateUrl: '/views/profile/block/contact.html',
          controller: 'ContactFormInstanceCtrl',
          resolve: {
            profile: function() {
              return profile;
            }
          }
        });
      }
    };
    return $rootScope.$on('profile-loaded', function(event, profile) {
      return $scope.checkFriend(profile.id);
    });
  });

  module.controller('ContactFormInstanceCtrl', function($scope, $modalInstance, $timeout, MakerScienceProfile, vcRecaptchaService, profile) {
    $scope.success = false;
    $scope.profile = profile;
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
        return MakerScienceProfile.one(profile.slug).customPOST(message, 'send/message', {}).then(function(response) {
          $scope.success = true;
          return $timeout($modalInstance.close, 3000);
        }, function(response) {
          return console.log("RECAPTCHA ERROR", response);
        });
      }
    };
  });

}).call(this);
