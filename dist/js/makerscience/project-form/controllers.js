(function() {
  var module;

  module = angular.module("makerscience.projects.controllers");

  module.controller("MakerScienceProjectSheetCreateCtrl", function($window, $scope, $state, $controller, $modal, $filter, $timeout, ProjectService, GalleryService, ProjectProgress, ProjectSheet, FormService, ProjectSheetQuestionAnswer, Project, MakerScienceProject, MakerScienceProjectLight, MakerScienceResource, MakerScienceProjectTaggedItem, ObjectProfileLink) {
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    $scope.projectsheet = {
      medias: []
    };
    $scope.QAItems = [];
    $scope.status2 = {};
    $scope.status1 = {};
    $scope.status2.open = false;
    FormService.init('projet-makerscience-2016').then(function(response) {
      $scope.QAItems = response.QAItems;
      return $scope.projectsheet = response.projectsheet;
    });
    $scope.themesTags = [];
    $scope.targetsTags = [];
    $scope.formatsTags = [];
    $scope.needs = [];
    $scope.newNeed = {};
    $scope.hideControls = false;
    $scope.medias = [];
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
    $scope.openInfosLink = function(projectsheet, QAItems) {
      var modalInstance;
      modalInstance = $modal.open({
        templateUrl: '/views/modal/infolink-modal.html',
        controller: 'InfoLinkCtrl',
        size: 'lg',
        backdrop: 'static',
        keyboard: false
      });
      return modalInstance.result.then(function(result) {
        $scope.$broadcast('images-added', result.img);
        $scope.status1.open = true;
        if (!$scope.projectsheet.project) {
          $scope.projectsheet.project = {};
        }
        $scope.projectsheet.project.title = result.url.title;
        $scope.projectsheet.project.website = result.url.url;
        $scope.status2.open = true;
        $scope.QAItems[0].answer = result.url.description;
        return $window.tinymce.editors[0].setContent(result.url.description);
      });
    };
    $scope.addNeed = function(need) {
      $scope.needs.push(angular.copy($scope.newNeed));
      return $scope.newNeed = {};
    };
    $scope.delNeed = function(index) {
      return $scope.needs.splice(index, 1);
    };
    return $scope.saveMakerscienceProject = function(form) {
      var field, requiredFields, _i, _len;
      requiredFields = ['projectName', 'projectBaseline', 'localisation'];
      for (_i = 0, _len = requiredFields.length; _i < _len; _i++) {
        field = requiredFields[_i];
        if (form[field].$error.required) {
          $scope.hideControls = false;
          return false;
        }
      }
      return FormService.save($scope.projectsheet).then(function(projectsheetResult) {
        var makerscienceProjectData;
        angular.forEach($scope.QAItems, function(q_a) {
          q_a.projectsheet = projectsheetResult.resource_uri;
          return ProjectSheetQuestionAnswer.post(q_a);
        });
        makerscienceProjectData = {
          parent: projectsheetResult.project.resource_uri
        };
        return MakerScienceProject.post(makerscienceProjectData).then(function(makerscienceProjectResult) {
          var promises, x, _j;
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
          if (_.size($scope.medias) === 0) {
            $scope.fake_progress = 0;
            for (x = _j = 1; _j <= 5; x = ++_j) {
              $scope.fake_progress += 100 / 5;
            }
            return $timeout(function() {
              return $state.go("project.detail", {
                slug: makerscienceProjectResult.parent.slug
              });
            }, 5000);
          } else {
            $scope.coverId = GalleryService.coverId;
            promises = [];
            angular.forEach($scope.medias, function(media, index) {
              var promise;
              promise = ProjectService.uploadMedia(media, projectsheetResult.bucket.id, projectsheetResult.id);
              promises.push(promise);
              return promise.then(function(res) {
                if ($scope.coverId === media.id) {
                  return ProjectSheet.one(projectsheetResult.id).patch({
                    cover: res.resource_uri
                  });
                }
              });
            });
            return Promise.all(promises).then(function() {
              return $state.go("project.detail", {
                slug: makerscienceProjectResult.parent.slug
              });
            })["catch"](function(err) {
              return console.error(err);
            });
          }
        });
      });
    };
  });

  module.controller("InfoLinkCtrl", function($scope, $modalInstance, MediaRestangular) {
    $scope.close = function() {
      return $modalInstance.dismiss('close');
    };
    return $scope.ok = function(link) {
      $scope.hideControls = true;
      console.log($scope);
      if ($scope.infoLinkForm.$invalid) {
        return false;
      }
      return MediaRestangular.one('geturl').get({
        'url': link.$modelValue
      }).then(function(resultUrl) {
        return MediaRestangular.one('getimg').get({
          'url': link.$modelValue
        }).then(function(resultImg) {
          var result;
          $scope.hideControls = false;
          result = {
            url: resultUrl,
            img: resultImg
          };
          return $modalInstance.close(result);
        })["catch"](function(err) {
          return console.error(err);
        });
      })["catch"](function(err) {
        return console.error(err);
      });
    };
  });

}).call(this);
