(function() {
  var module;

  module = angular.module("makerscience.catalog.controllers.project", ['makerscience.catalog.services', "makerscience.catalog.controllers.generic", 'commons.graffiti.controllers', "commons.accounts.controllers", 'makerscience.base.services', 'makerscience.base.controllers']);

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

  module.controller("MakerScienceProjectSheetCreateCtrl", function($scope, $state, $controller, $filter, $timeout, ProjectProgress, ProjectSheet, MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerScienceProjectTaggedItem, ObjectProfileLink) {
    $controller('ProjectSheetCreateCtrl', {
      $scope: $scope
    });
    $controller('MakerScienceLinkedResourceCtrl', {
      $scope: $scope
    });
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    $scope.themesTags = [];
    $scope.targetsTags = [];
    $scope.formatsTags = [];
    $scope.needs = [];
    $scope.newNeed = {};
    $scope.hideControls = false;
    $scope.initProjectSheetCreateCtrl('projet-makerscience');
    ProjectProgress.getList({
      'range__slug': 'makerscience'
    }).then(function(progressRangeResult) {
      var progress;
      return $scope.progressRange = [
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
    });
    $scope.addNeed = function(need) {
      $scope.needs.push(angular.copy($scope.newNeed));
      return $scope.newNeed = {};
    };
    $scope.delNeed = function(index) {
      return $scope.needs.splice(index, 1);
    };
    return $scope.saveMakerscienceProject = function(formIsValid) {
      if (!formIsValid) {
        console.log(" Form invalid !");
        $scope.hideControls = false;
        return false;
      } else {
        console.log("submitting form");
      }
      return $scope.saveProject().then(function(projectsheetResult) {
        var makerscienceProjectData;
        makerscienceProjectData = {
          parent: projectsheetResult.project.resource_uri,
          linked_resources: $scope.linkedResources.map(function(resource) {
            return resource.resource_uri;
          })
        };
        return MakerScienceProject.post(makerscienceProjectData).then(function(makerscienceProjectResult) {
          var x, _i;
          ObjectProfileLink.one().customPOST({
            profile_id: $scope.currentMakerScienceProfile.parent.id,
            level: 0,
            detail: "Créateur/Créatrice",
            isValidated: true
          }, 'makerscienceproject/' + makerscienceProjectResult.id);
          angular.forEach($scope.themesTags, function(tag) {
            return MakerScienceProjectTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceproject/" + makerscienceProjectResult.id + "/th", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          angular.forEach($scope.formatsTags, function(tag) {
            return MakerScienceProjectTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceproject/" + makerscienceProjectResult.id + "/fm", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          angular.forEach($scope.targetsTags, function(tag) {
            return MakerScienceProjectTaggedItem.one().customPOST({
              tag: tag.text
            }, "makerscienceproject/" + makerscienceProjectResult.id + "/tg", {}).then(function(taggedItemResult) {
              return ObjectProfileLink.one().customPOST({
                profile_id: $scope.currentMakerScienceProfile.parent.id,
                level: 50,
                detail: '',
                isValidated: true
              }, 'taggeditem/' + taggedItemResult.id);
            });
          });
          MakerScienceProjectLight.one(makerscienceProjectResult.id).get().then(function(projectResult) {
            return angular.forEach($scope.needs, function(needPost) {
              needPost.linked_projects = [projectResult.resource_uri];
              needPost.type = 'need';
              return $scope.saveMakersciencePost(needPost, null, $scope.currentMakerScienceProfile.parent);
            });
          });
          ProjectSheet.one(projectsheetResult.id).patch({
            videos: $scope.projectsheet.videos
          });
          if ($scope.uploader.queue.length === 0) {
            $scope.fake_progress = 0;
            for (x = _i = 1; _i <= 5; x = ++_i) {
              $scope.fake_progress += 100 / 5;
            }
            return $timeout(function() {
              return $state.go("project.detail", {
                slug: makerscienceProjectResult.parent.slug
              });
            }, 5000);
          } else {
            $scope.uploader.onBeforeUploadItem = function(item) {
              item.formData.push({
                bucket: projectsheetResult.bucket.id
              });
              return item.headers = {
                Authorization: $scope.uploader.headers["Authorization"]
              };
            };
            $scope.uploader.onCompleteItem = function(fileItem, response, status, headers) {
              if ($scope.uploader.getIndexOfItem(fileItem) === $scope.coverIndex) {
                return ProjectSheet.one(projectsheetResult.id).patch({
                  cover: response.resource_uri
                });
              }
            };
            $scope.uploader.onCompleteAll = function() {
              return $state.go("project.detail", {
                slug: makerscienceProjectResult.parent.slug
              });
            };
            return $scope.uploader.uploadAll();
          }
        });
      });
    };
  });

  module.controller("NewNeedPopupInstanceCtrl", function($scope, $controller, $modalInstance, projectsheet, MakerScienceProjectLight, MakerSciencePostLight) {
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    $scope.newNeed = {
      title: '',
      text: '',
      type: 'need'
    };
    $scope.ok = function() {
      $scope.errors = [];
      if ($scope.newNeed.title === "") {
        $scope.errors.push("title");
      }
      if (String($scope.newNeed.text).replace(/<[^>]+>/gm, '') === "") {
        $scope.errors.push("text");
      }
      if ($scope.errors.length === 0) {
        MakerScienceProjectLight.one(projectsheet.id).get().then(function(projectResult) {
          $scope.newNeed.linked_projects = [projectResult.resource_uri];
          return $scope.saveMakersciencePost($scope.newNeed, null, $scope.currentMakerScienceProfile.parent).then(function(postResult) {
            return MakerSciencePostLight.one(postResult.id).get().then(function(post) {
              post.author = $scope.currentMakerScienceProfile.parent;
              return projectsheet.linked_makersciencepost.push(post);
            });
          });
        });
        return $modalInstance.close();
      }
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

  module.controller("MakerScienceProjectSheetCtrl", function($rootScope, $scope, $stateParams, $controller, $filter, $window, $modal, MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerSciencePostLight, MakerScienceProjectTaggedItem, TaggedItem, ProjectProgress, ProjectNews, Comment, ObjectProfileLink, DataSharing) {
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
    $controller('PostCtrl', {
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
    MakerScienceProject.one().get({
      'parent__slug': $stateParams.slug
    }).then(function(makerScienceProjectResult) {
      $scope.projectsheet = makerScienceProjectResult.objects[0];
      $scope.editable = $scope.projectsheet.can_edit;
      $scope.initCommunityCtrl("makerscienceproject", $scope.projectsheet.id);
      $scope.initCommentCtrl("makerscienceproject", $scope.projectsheet.id);
      $scope.linkedResources = $scope.projectsheet.linked_resources;
      $scope.fetchCoverURL($scope.projectsheet.base_projectsheet);
      $scope.$on('cover-updated', function() {
        return $scope.fetchCoverURL($scope.projectsheet.base_projectsheet);
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
      if (_.isEmpty($scope.projectsheet.base_projectsheet.videos)) {
        $scope.projectsheet.base_projectsheet.videos = null;
      }
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
      $scope.openNewNeedPopup = function() {
        var modalInstance;
        return modalInstance = $modal.open({
          templateUrl: '/views/catalog/block/newNeedPopup.html',
          controller: 'NewNeedPopupInstanceCtrl',
          resolve: {
            projectsheet: function() {
              return $scope.projectsheet;
            }
          }
        });
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
      $scope.updateLinkedResources = function() {
        return MakerScienceProject.one($scope.projectsheet.id).patch({
          linked_resources: $scope.linkedResources.map(function(resource) {
            return resource.resource_uri;
          })
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
