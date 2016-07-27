(function() {
  var module;

  module = angular.module("makerscience.resources.controllers", ["commons.accounts.controllers", 'makerscience.base.services', 'commons.tags.services', 'makerscience.base.controllers']);

  module.controller("MakerScienceResourceListCtrl", function($scope, $controller, StaticContent, MakerScienceResourceLight, MakerScienceResourceTaggedItem, FilterService) {
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
        var nbElmt, rand, tmp, _results;
        nbElmt = $scope.resources.length;
        _results = [];
        while (nbElmt) {
          rand = Math.floor(Math.random() * nbElmt--);
          tmp = $scope.resources[nbElmt];
          $scope.resources[nbElmt] = $scope.resources[rand];
          _results.push($scope.resources[rand] = tmp);
        }
        return _results;
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

  module.controller("MakerScienceResourceSheetCtrl", function($rootScope, $scope, $stateParams, $controller, $modal, $filter, ProjectService, TaggedItemService, MakerScienceResource, MakerScienceResourceLight, MakerScienceResourceTaggedItem, MakerSciencePostLight, TaggedItem, Comment, ObjectProfileLink, DataSharing) {
    $controller('VoteCtrl', {
      $scope: $scope
    });
    $scope.openTagPopup = function(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) {
      return TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback);
    };
    $scope.preparedThemeTags = [];
    $scope.preparedFormatsTags = [];
    $scope.preparedTargetTags = [];
    $scope.editable = false;
    $scope.objectId = null;
    $scope.medias = [];
    MakerScienceResource.one().get({
      'parent__slug': $stateParams.slug
    }).then(function(makerScienceResourceResult) {
      var coverId;
      $scope.projectsheet = $scope.resourcesheet = makerScienceResourceResult.objects[0];
      $scope.objectId = $scope.projectsheet.id;
      $scope.editable = $scope.projectsheet.can_edit;
      console.log($scope.projectsheet);
      $scope.getFilterMedias = function() {
        $scope.mediasToShow = $filter('filter')($scope.projectsheet.base_projectsheet.bucket.files, {
          type: '!cover'
        });
        $scope.filteredByAuthor = $filter('filter')($scope.mediasToShow, {
          is_author: true,
          type: '!experience'
        });
        $scope.filteredByNotAuthor = $filter('filter')($scope.mediasToShow, {
          is_author: false,
          type: '!experience'
        });
        return $scope.filteredByExperience = $filter('filter')($scope.mediasToShow, {
          type: 'experience'
        });
      };
      $scope.getFilterMedias();
      $scope.openGallery = function(projectsheet) {
        var modalInstance;
        modalInstance = $modal.open({
          templateUrl: '/views/gallery/gallery-resource-modal.html',
          controller: 'GalleryEditionInstanceCtrl',
          size: 'lg',
          backdrop: 'static',
          keyboard: false,
          resolve: {
            projectsheet: function() {
              return projectsheet;
            },
            medias: function() {
              return $scope.medias;
            }
          }
        });
        return modalInstance.result.then(function(result) {
          $scope.$emit('cover-updated');
          return $scope.medias = [];
        });
      };
      $scope.openCover = function(projectsheet) {
        var modalInstance;
        modalInstance = $modal.open({
          templateUrl: '/views/modal/cover-modal.html',
          controller: 'CoverResourceSheetCtrl',
          size: 'lg',
          backdrop: 'static',
          keyboard: false,
          resolve: {
            base_projectsheet: function() {
              return $scope.projectsheet.base_projectsheet;
            }
          }
        });
        return modalInstance.result.then(function(result) {
          var coverId;
          $scope.projectsheet.base_projectsheet.cover = result;
          coverId = $scope.projectsheet.base_projectsheet.cover ? $scope.projectsheet.base_projectsheet.cover.id : null;
          return $scope.coverURL = ProjectService.fetchCoverURL($scope.projectsheet.base_projectsheet.cover);
        });
      };
      $scope.updateProjectSheet = function(resourceName, resourceId, fieldName, data) {
        var resources;
        resources = {
          resourceName: resourceName,
          resourceId: resourceId,
          fieldName: fieldName,
          data: data
        };
        return ProjectService.updateProjectSheet(resources, $scope.projectsheet);
      };
      coverId = $scope.projectsheet.base_projectsheet.cover ? $scope.projectsheet.base_projectsheet.cover.id : null;
      $scope.coverURL = ProjectService.fetchCoverURL(coverId);
      $scope.$on('cover-updated', function() {
        return MakerScienceResource.one().get({
          'parent__slug': $stateParams.slug
        }).then(function(makerScienceResourceResult) {
          $scope.projectsheet = makerScienceResourceResult.objects[0];
          return $scope.getFilterMedias();
        });
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

  module.controller("CoverResourceSheetCtrl", function($scope, $modalInstance, ProjectService, ProjectSheet, base_projectsheet, GalleryService) {
    $scope.resourceCover = {
      type: 'cover'
    };
    $scope.ok = function() {
      $scope.hideControls = true;
      if ($scope.resourceCover.file) {
        return ProjectService.uploadMedia($scope.resourceCover, base_projectsheet.bucket.id, base_projectsheet.id).then(function(res) {
          $scope.hideControls = false;
          ProjectSheet.one(base_projectsheet.id).patch({
            cover: res.resource_uri
          });
          return $modalInstance.close(res);
        });
      } else {
        return $modalInstance.close(null);
      }
    };
    $scope.close = function() {
      return $modalInstance.dismiss('cancel');
    };
    return $scope.change = function() {
      return scope.$apply(function() {
        return scope.coverForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type));
      });
    };
  });

}).call(this);
