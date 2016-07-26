(function() {
  var module;

  module = angular.module('makerscience.projects.controllers');

  module.controller("MakerScienceResourceSheetCreateCtrl", function($scope, $state, $controller, $timeout, ProjectSheet, FormService, ProjectService, GalleryService, MakerScienceResource, MakerScienceResourceTaggedItem, ObjectProfileLink) {
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {
      $scope: $scope
    }));
    $scope.projectsheet = {};
    $scope.QAItems = [];
    FormService.init('experience-makerscience').then(function(response) {
      $scope.QAItems = response.QAItems;
      return $scope.projectsheet = response.projectsheet;
    });
    $scope.resourceCover = {
      type: 'cover',
      title: 'cover'
    };
    $scope.themesTags = [];
    $scope.targetsTags = [];
    $scope.formatsTags = [];
    $scope.medias = [];
    $scope.hideControls = false;
    $scope.changeCover = function() {
      return $scope.$apply(function() {
        $scope.newResourceForm.$setValidity('imageFileFormat', true);
        if ($scope.resourceCover.file) {
          return $scope.newResourceForm.$setValidity('imageFileFormat', GalleryService.isTypeImage($scope.resourceCover.file.type));
        }
      });
    };
    return $scope.saveMakerscienceResource = function(newResourceForm) {
      var isValid;
      isValid = !newResourceForm.resourceName.$error.required && !newResourceForm.projectBaseline.$error.required;
      if (!isValid) {
        console.log(" Form invalid !");
        $scope.hideControls = false;
        return false;
      } else {
        console.log("submitting form");
      }
      return FormService.save($scope.projectsheet).then(function(resourcesheetResult) {
        var makerscienceResourceData;
        makerscienceResourceData = {
          parent: resourcesheetResult.project.resource_uri,
          duration: $scope.projectsheet.duration
        };
        return MakerScienceResource.post(makerscienceResourceData).then(function(makerscienceResourceResult) {
          var promises, x, _i;
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
          if ($scope.resourceCover) {
            ProjectService.uploadMedia($scope.resourceCover, resourcesheetResult.bucket.id, resourcesheetResult.id).then(function(res) {
              return ProjectSheet.one(resourcesheetResult.id).patch({
                cover: res.resource_uri
              });
            });
          }
          if (_.size($scope.medias) === 0) {
            $scope.fake_progress = 0;
            for (x = _i = 1; _i <= 5; x = ++_i) {
              $scope.fake_progress += 100 / 5;
            }
            return $timeout(function() {
              return $state.go("resource.detail", {
                slug: makerscienceResourceResult.parent.slug
              });
            }, 5000);
          } else {
            promises = [];
            angular.forEach($scope.medias, function(media, index) {
              var promise;
              console.log(media);
              promise = ProjectService.uploadMedia(media, resourcesheetResult.bucket.id, resourcesheetResult.id);
              return promises.push(promise);
            });
            return Promise.all(promises).then(function() {
              return $state.go("resource.detail", {
                slug: makerscienceResourceResult.parent.slug
              });
            })["catch"](function(err) {
              return console.error(err);
            });
          }
        });
      });
    };
  });

}).call(this);
