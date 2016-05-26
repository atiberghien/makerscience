(function() {
  var module;

  module = angular.module("makerscience.catalog.controllers.resource", ['makerscience.catalog.services', "makerscience.catalog.controllers.generic", 'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services', 'makerscience.base.controllers']);

  module.controller("MakerScienceResourceListCtrl", function($scope, $controller, StaticContent, MakerScienceResourceLight, MakerScienceResourceTaggedItem) {
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {
      $scope: $scope
    }));
    $scope.params["limit"] = $scope.limit = 6;
    $scope.selected_themes = [];
    $scope.selected_themes_facets = "";
    StaticContent.one(1).get().then(function(staticResult) {
      return angular.forEach(staticResult.project_thematic_selection, function(tag) {
        if ($scope.selected_themes_facets !== "") {
          $scope.selected_themes_facets += ",";
        }
        $scope.selected_themes_facets += tag.slug;
        return $scope.selected_themes.push(tag);
      });
    });
    $scope.clearList = function() {
      $scope.$broadcast('clearFacetFilter');
      $scope.resources = [];
      return $scope.waitingList = true;
    };
    $scope.refreshList = function() {
      return MakerScienceResourceLight.one().customGETLIST('search', $scope.params).then(function(makerScienceResourceResults) {
        var meta;
        meta = makerScienceResourceResults.metadata;
        $scope.totalItems = meta.total_count;
        $scope.limit = meta.limit;
        $scope.resources = makerScienceResourceResults;
        return $scope.waitingList = false;
      });
    };
    $scope.initMakerScienceAbstractListCtrl();
    $scope.fetchRecentResources = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-created_on';
      return $scope.refreshList();
    };
    $scope.fetchTopResources = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-total_score';
      return $scope.refreshList();
    };
    $scope.fetchRandomResources = function() {
      $scope.$broadcast('clearFacetFilter');
      delete $scope.params['ordering'];
      return $scope.refreshList().then(function() {
        var nbElmt, rand, results, tmp;
        nbElmt = $scope.resources.length;
        results = [];
        while (nbElmt) {
          rand = Math.floor(Math.random() * nbElmt--);
          tmp = $scope.resources[nbElmt];
          $scope.resources[nbElmt] = $scope.resources[rand];
          results.push($scope.resources[rand] = tmp);
        }
        return results;
      });
    };
    $scope.fetchThematicResources = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-created_on';
      return FilterService.filterParams.tags = $scope.selected_themes_facets;
    };
    $scope.fetchRecentResources();
    $scope.availableThemeTags = [];
    $scope.availableFormatsTags = [];
    $scope.availableTargetTags = [];
    return MakerScienceResourceTaggedItem.getList({
      distinct: 'True'
    }).then(function(taggedItemResults) {
      return angular.forEach(taggedItemResults, function(taggedItem) {
        switch (taggedItem.tag_type) {
          case 'th':
            return $scope.availableThemeTags.push(taggedItem.tag);
          case 'fm':
            return $scope.availableFormatsTags.push(taggedItem.tag);
          case 'tg':
            return $scope.availableTargetTags.push(taggedItem.tag);
        }
      });
    });
  });

  module.controller("MakerScienceResourceSheetCreateCtrl", function($scope, $state, $controller, $timeout, ProjectSheet, MakerScienceResource, MakerScienceResourceTaggedItem, ObjectProfileLink) {
    $controller('ProjectSheetCreateCtrl', {
      $scope: $scope
    });
    $controller('MakerScienceLinkedResourceCtrl', {
      $scope: $scope
    });
    $scope.themesTags = [];
    $scope.targetsTags = [];
    $scope.formatsTags = [];
    $scope.hideControls = false;
    $scope.initProjectSheetCreateCtrl('experience-makerscience');
    return $scope.saveMakerscienceResource = function(formIsValid) {
      if (!formIsValid) {
        console.log(" Form invalid !");
        $scope.hideControls = false;
        return false;
      } else {
        console.log("submitting form");
      }
      return $scope.saveProject().then(function(resourcesheetResult) {
        var makerscienceResourceData;
        makerscienceResourceData = {
          parent: resourcesheetResult.project.resource_uri,
          duration: $scope.projectsheet.duration,
          linked_resources: $scope.linkedResources.map(function(resource) {
            return resource.resource_uri;
          })
        };
        return MakerScienceResource.post(makerscienceResourceData).then(function(makerscienceResourceResult) {
          var i, x;
          ObjectProfileLink.one().customPOST({
            profile_id: $scope.currentMakerScienceProfile.parent.id,
            level: 10,
            detail: "Créateur/Créatrice",
            isValidated: true
          }, 'makerscienceresource/' + makerscienceResourceResult.id);
          angular.forEach($scope.themesTags, function(tag) {
            return MakerScienceResourceTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceresource/" + makerscienceResourceResult.id + "/th", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          angular.forEach($scope.formatsTags, function(tag) {
            return MakerScienceResourceTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceresource/" + makerscienceResourceResult.id + "/fm", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          angular.forEach($scope.targetsTags, function(tag) {
            return MakerScienceResourceTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceresource/" + makerscienceResourceResult.id + "/tg", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          ProjectSheet.one(resourcesheetResult.id).patch({
            videos: $scope.projectsheet.videos
          });
          if ($scope.uploader.queue.length === 0) {
            $scope.fake_progress = 0;
            for (x = i = 1; i <= 5; x = ++i) {
              $scope.fake_progress += 100 / 5;
            }
            return $timeout(function() {
              return $state.go("resource.detail", {
                slug: makerscienceResourceResult.parent.slug
              });
            }, 5000);
          } else {
            $scope.uploader.onBeforeUploadItem = function(item) {
              item.formData.push({
                bucket: resourcesheetResult.bucket.id
              });
              return item.headers = {
                Authorization: $scope.uploader.headers["Authorization"]
              };
            };
            $scope.uploader.onCompleteItem = function(fileItem, response, status, headers) {
              if ($scope.uploader.getIndexOfItem(fileItem) === $scope.coverIndex) {
                return ProjectSheet.one(resourcesheetResult.id).patch({
                  cover: response.resource_uri
                });
              }
            };
            $scope.uploader.onCompleteAll = function() {
              return $state.go("resource.detail", {
                slug: makerscienceResourceResult.parent.slug
              });
            };
            return $scope.uploader.uploadAll();
          }
        });
      });
    };
  });

  module.controller("MakerScienceResourceSheetCtrl", function($rootScope, $scope, $stateParams, $controller, MakerScienceResource, MakerScienceResourceLight, MakerScienceResourceTaggedItem, MakerSciencePostLight, TaggedItem, Comment, ObjectProfileLink, DataSharing) {
    $controller('ProjectSheetCtrl', {
      $scope: $scope,
      $stateParams: $stateParams
    });
    $controller('TaggedItemCtrl', {
      $scope: $scope
    });
    $controller('MakerScienceLinkedResourceCtrl', {
      $scope: $scope
    });
    $controller('VoteCtrl', {
      $scope: $scope
    });
    angular.extend(this, $controller('CommunityCtrl', {
      $scope: $scope
    }));
    angular.extend(this, $controller('CommentCtrl', {
      $scope: $scope
    }));
    $scope.preparedThemeTags = [];
    $scope.preparedFormatsTags = [];
    $scope.preparedTargetTags = [];
    $scope.editable = false;
    MakerScienceResource.one().get({
      'parent__slug': $stateParams.slug
    }).then(function(makerScienceResourceResult) {
      $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0];
      $scope.editable = $scope.projectsheet.can_edit;
      $scope.initCommunityCtrl("makerscienceresource", $scope.projectsheet.id);
      $scope.initCommentCtrl("makerscienceresource", $scope.projectsheet.id);
      $scope.linkedResources = $scope.projectsheet.linked_resources;
      $scope.fetchCoverURL($scope.projectsheet.base_projectsheet);
      $scope.$on('cover-updated', function() {
        return $scope.fetchCoverURL($scope.projectsheet.base_projectsheet);
      });
      $scope.similars = [];
      TaggedItem.one().customGET("makerscienceresource/" + $scope.resourcesheet.id + "/similars").then(function(similarResults) {
        return angular.forEach(similarResults, function(similar) {
          if (similar.type === 'makerscienceresource') {
            return $scope.similars.push(MakerScienceResourceLight.one(similar.id).get().$object);
          }
        });
      });
      angular.forEach($scope.projectsheet.tags, function(taggedItem) {
        switch (taggedItem.tag_type) {
          case "th":
            return $scope.preparedThemeTags.push({
              text: taggedItem.tag.name,
              slug: taggedItem.tag.slug,
              taggedItemId: taggedItem.id
            });
          case "tg":
            return $scope.preparedTargetTags.push({
              text: taggedItem.tag.name,
              slug: taggedItem.tag.slug,
              taggedItemId: taggedItem.id
            });
          case "fm":
            return $scope.preparedFormatsTags.push({
              text: taggedItem.tag.name,
              slug: taggedItem.tag.slug,
              taggedItemId: taggedItem.id
            });
        }
      });
      if (_.isEmpty($scope.resourcesheet.base_projectsheet.videos)) {
        $scope.resourcesheet.base_projectsheet.videos = null;
      }
      $scope.updateLinkedResources = function() {
        return MakerScienceResource.one($scope.projectsheet.id).patch({
          linked_resources: $scope.linkedResources.map(function(resource) {
            return resource.resource_uri;
          })
        });
      };
      return $scope.$watch('currentMakerScienceProfile', function(newValue, oldValue) {
        if (newValue !== null && newValue !== void 0) {
          $scope.addTagToResourceSheet = function(tag_type, tag) {
            return MakerScienceResourceTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceresource/" + $scope.projectsheet.id + "/" + tag_type, {}).then(function(taggedItemResult) {
              ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
              return tag.taggedItemId = taggedItemResult.id;
            });
          };
          $scope.removeTagFromResourceSheet = function(tag) {
            return MakerScienceResourceTaggedItem.one(tag.taggedItemId).remove();
          };
          $scope.saveMakerScienceResourceVote = function(voteType, score) {
            return $scope.saveVote($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id, voteType, score, 14);
          };
          return $scope.loadVotes($scope.currentMakerScienceProfile.parent.id, 'makerscienceresource', $scope.resourcesheet.id);
        } else {
          return $scope.loadVotes(null, 'makerscienceresource', $scope.resourcesheet.id);
        }
      });
    });
    return $scope.updateMakerScienceResourceSheet = function(resourceName, resourceId, fieldName, data) {
      var putData;
      putData = {};
      putData[fieldName] = data;
      switch (resourceName) {
        case 'MakerScienceResource':
          return MakerScienceResource.one(resourceId).patch(putData);
      }
    };
  });

}).call(this);
