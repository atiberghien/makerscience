(function() {
  var module;

  module = angular.module("makerscience.projects.controllers", ["commons.accounts.controllers", 'makerscience.base.services', 'commons.tags.services', 'makerscience.base.controllers']);

  module.controller("MakerScienceProjectListCtrl", function($scope, $controller, MakerScienceProjectLight, StaticContent, FilterService, MakerScienceProjectTaggedItem) {
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
      $scope.projects = [];
      return $scope.waitingList = true;
    };
    $scope.refreshList = function() {
      return MakerScienceProjectLight.one().customGETLIST('search', $scope.params).then(function(makerScienceProjectResults) {
        var meta;
        meta = makerScienceProjectResults.metadata;
        $scope.totalItems = meta.total_count;
        $scope.limit = meta.limit;
        $scope.projects = makerScienceProjectResults;
        return $scope.waitingList = false;
      });
    };
    $scope.initMakerScienceAbstractListCtrl();
    $scope.fetchRecentProjects = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-created_on';
      return $scope.refreshList();
    };
    $scope.fetchTopProjects = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-total_score';
      return $scope.refreshList();
    };
    $scope.fetchRandomProjects = function() {
      $scope.clearList();
      delete $scope.params['ordering'];
      return $scope.refreshList().then(function() {
        var nbElmt, rand, tmp, _results;
        nbElmt = $scope.projects.length;
        _results = [];
        while (nbElmt) {
          rand = Math.floor(Math.random() * nbElmt--);
          tmp = $scope.projects[nbElmt];
          $scope.projects[nbElmt] = $scope.projects[rand];
          _results.push($scope.projects[rand] = tmp);
        }
        return _results;
      });
    };
    $scope.fetchThematicProjects = function() {
      $scope.clearList();
      $scope.params['ordering'] = '-created_on';
      return FilterService.filterParams.tags = $scope.selected_themes_facets;
    };
    $scope.fetchRecentProjects();
    $scope.availableThemeTags = [];
    $scope.availableFormatsTags = [];
    $scope.availableTargetTags = [];
    return MakerScienceProjectTaggedItem.getList({
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

  module.controller("MakerScienceProjectSheetCtrl", function($rootScope, $scope, $stateParams, $controller, $filter, $window, $modal, ProjectService, TaggedItemService, GalleryService, MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerSciencePostLight, MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress, ProjectNews, Comment, ObjectProfileLink, DataSharing) {
    $controller('VoteCtrl', {
      $scope: $scope
    });
    $controller('PostCtrl', {
      $scope: $scope
    });
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    $scope.openTagPopup = function(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) {
      return TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback);
    };
    $scope.preparedThemeTags = [];
    $scope.preparedFormatsTags = [];
    $scope.preparedTargetTags = [];
    $scope.editable = false;
    $scope.objectId = null;
    $scope.medias = [];
    MakerScienceProject.one().get({
      'parent__slug': $stateParams.slug
    }).then(function(makerScienceProjectResult) {
      var coverId;
      $scope.projectsheet = makerScienceProjectResult.objects[0];
      $scope.editable = $scope.projectsheet.can_edit;
      $scope.objectId = $scope.projectsheet.id;
      $scope.hasPictures = false;
      $scope.hasVideos = false;
      angular.forEach($scope.projectsheet.news, function(news, index) {
        return news.summary = $filter('getSummary')(news.text);
      });
      $scope.checkFiles = function() {
        var hasPictures, hasVideos;
        hasPictures = _.findIndex($scope.projectsheet.base_projectsheet.bucket.files, {
          'type': 'image'
        });
        hasVideos = _.findIndex($scope.projectsheet.base_projectsheet.bucket.files, {
          'type': 'video'
        });
        $scope.hasPictures = hasPictures === -1 ? false : true;
        return $scope.hasVideos = hasVideos === -1 ? false : true;
      };
      $scope.setMediasToShow = function() {
        $scope.mediasToShow = [];
        return angular.forEach($scope.projectsheet.base_projectsheet.bucket.files, function(media, index) {
          if (media.type === 'document' || media.type === 'link') {
            return $scope.mediasToShow.push(media);
          }
        });
      };
      $scope.checkFiles();
      $scope.setMediasToShow();
      $scope.openGallery = function(projectsheet) {
        var modalInstance;
        modalInstance = $modal.open({
          templateUrl: '/views/gallery/gallery-project-modal.html',
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
      $scope.coverURL = ProjectService.fetchCoverURL($scope.projectsheet.base_projectsheet.cover);
      $scope.$on('cover-updated', function() {
        console.log($scope);
        return MakerScienceProject.one().get({
          'parent__slug': $stateParams.slug
        }).then(function(makerScienceProjectResult) {
          var newCover;
          $scope.projectsheet = makerScienceProjectResult.objects[0];
          if (GalleryService.coverId !== coverId) {
            coverId = GalleryService.coverId;
            newCover = GalleryService.coverId === null ? null : $scope.projectsheet.base_projectsheet.cover;
            $scope.coverURL = ProjectService.fetchCoverURL(newCover);
          }
          $scope.setMediasToShow();
          return $scope.checkFiles();
        });
      });
      $scope.similars = [];
      TaggedItem.one().customGET("makerscienceproject/" + $scope.projectsheet.id + "/similars").then(function(similarResults) {
        return angular.forEach(similarResults, function(similar) {
          if (similar.type === 'makerscienceproject') {
            return $scope.similars.push(MakerScienceProjectLight.one(similar.id).get().$object);
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
      $scope.need_length = $filter('filter')($scope.projectsheet.linked_makersciencepost, {
        post_type: 'need'
      }).length;
      angular.forEach($scope.projectsheet.linked_makersciencepost, function(makerSciencePostResult) {
        $scope.getPostAuthor(makerSciencePostResult.parent_id).then(function(author) {
          return makerSciencePostResult.author = author;
        });
        return $scope.getContributors(makerSciencePostResult.parent_id).then(function(contributors) {
          return makerSciencePostResult.contributors = contributors;
        });
      });
      $scope.newsData = {};
      $scope.publishNews = function() {
        var newsText;
        newsText = String($scope.newsData.text).replace(/<[^>]+>/gm, '');
        if ($scope.newsData.title === '' || $scope.newsData.title === void 0 || newsText === '' || newsText === 'undefined') {
          return false;
        }
        $scope.newsData.author = $scope.currentMakerScienceProfile.parent.id;
        $scope.newsData.project = $scope.projectsheet.parent.id;
        return MakerScienceProject.one().customPOST($scope.newsData, 'publish/news').then(function(newsResult) {
          ObjectProfileLink.one().customPOST({
            profile_id: $scope.currentMakerScienceProfile.parent.id,
            level: 7,
            detail: '',
            isValidated: true
          }, 'projectnews/' + newsResult.id);
          $scope.projectsheet.news.unshift(newsResult);
          angular.copy({}, $scope.newsData);
          return $window.tinymce.activeEditor.setContent('');
        });
      };
      $scope.newNeed = {
        title: '',
        text: '',
        type: 'need'
      };
      $scope.needFormSent = false;
      $scope.addNeed = function() {
        $scope.needFormSent = true;
        $scope.errors = [];
        if ($scope.newNeed.title === "") {
          $scope.errors.push("title");
        }
        if (String($scope.newNeed.text).replace(/<[^>]+>/gm, '') === "") {
          $scope.errors.push("text");
        }
        if ($scope.errors.length === 0) {
          return MakerScienceProjectLight.one($scope.projectsheet.id).get().then(function(projectResult) {
            $scope.newNeed.linked_projects = [projectResult.resource_uri];
            return $scope.saveMakersciencePost($scope.newNeed, null, $scope.currentMakerScienceProfile.parent).then(function(postResult) {
              return MakerSciencePostLight.one(postResult.id).get().then(function(post) {
                post.author = $scope.currentMakerScienceProfile.parent;
                $scope.projectsheet.linked_makersciencepost.push(post);
                return $scope.needFormSent = false;
              });
            });
          });
        }
      };
      $scope.deleteNews = function(news) {
        return ProjectNews.one(news.id).remove().then(function() {
          return $scope.projectsheet.news.splice($scope.projectsheet.news.indexOf(news), 1);
        });
      };
      $scope.updateNews = function(news) {
        return ProjectNews.one(news.id).patch({
          text: news.text
        }).then(function() {
          return $scope.projectsheet.news[$scope.projectsheet.news.indexOf(news)].text = news.text;
        });
      };
      ProjectProgress.getList({
        'range__slug': 'makerscience'
      }).then(function(progressRangeResult) {
        var progress;
        $scope.progressRange = [
          (function() {
            var _i, _len, _ref, _results;
            _ref = $filter('orderBy')(progressRangeResult, 'order');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              progress = _ref[_i];
              _results.push({
                value: progress.resource_uri,
                text: progress.label
              });
            }
            return _results;
          })()
        ][0];
        return $scope.showProjectProgress = function() {
          var selected;
          selected = $filter('filter')($scope.progressRange, {
            value: $scope.projectsheet.parent.progress.resource_uri
          });
          if ($scope.projectsheet.parent.progress.label && selected.length) {
            return selected[0].text;
          } else {
            return 'non renseigné';
          }
        };
      });
      return $scope.$watch('currentMakerScienceProfile', function(newValue, oldValue) {
        if (newValue !== null && newValue !== void 0) {
          $scope.addTagToProjectSheet = function(tag_type, tag) {
            return MakerScienceProjectTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceproject/" + $scope.projectsheet.id + "/" + tag_type, {}).then(function(taggedItemResult) {
              ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
              return tag.taggedItemId = taggedItemResult.id;
            });
          };
          $scope.removeTagFromProjectSheet = function(tag) {
            return MakerScienceProjectTaggedItem.one(tag.taggedItemId).remove();
          };
          $scope.saveMakerScienceProjectVote = function(voteType, score) {
            return $scope.saveVote($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id, voteType, score, 4);
          };
          return $scope.loadVotes($scope.currentMakerScienceProfile.parent.id, 'makerscienceproject', $scope.projectsheet.id);
        } else {
          return $scope.loadVotes(null, 'makerscienceproject', $scope.projectsheet.id);
        }
      });
    });
    return $scope.updateMakerScienceProjectSheet = function(resourceName, resourceId, fieldName, data) {
      var putData;
      putData = {};
      putData[fieldName] = data;
      switch (resourceName) {
        case 'MakerScienceProject':
          return MakerScienceProject.one(resourceId).patch(putData);
      }
    };
  });

}).call(this);
