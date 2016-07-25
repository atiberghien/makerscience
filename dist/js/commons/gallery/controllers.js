(function() {
  var module;

  module = angular.module('commons.gallery.controllers', []);

  module.controller('GalleryCreationProjectCtrl', function($scope, GalleryService, ProjectSheet, BucketFile, ProjectService) {
    $scope.config = config;
    $scope.newMedia = GalleryService.initMediaProject('image');
    $scope.$on('images-added', function(event, data) {
      return angular.forEach(data, function(img, index) {
        return $scope.medias.push({
          type: 'image',
          title: img.alt,
          url: img.src
        });
      });
    });
    $scope.coverId = $scope.projectsheet.cover ? $scope.projectsheet.cover.id : null;
    GalleryService.setCoverId($scope.coverId);
    $scope.getMediasToShow = function() {
      return $scope.mediasToShow = $scope.projectsheet.bucket ? $scope.medias.concat($scope.projectsheet.bucket.files) : $scope.medias;
    };
    $scope.getMediasToShow();
    $scope.changeTab = function(type) {
      $scope.newMedia.type = type;
      $scope.newMedia.file = null;
      return $scope.newMedia.url = null;
    };
    $scope.toggleCoverCandidate = function(media) {
      $scope.coverId = GalleryService.setCoverId(media.id);
      if ($scope.projectsheet.id) {
        $scope.projectsheet.cover = media;
        return ProjectSheet.one($scope.projectsheet.id).patch({
          cover: media.resource_uri
        });
      }
    };
    $scope.addMedia = function(newMedia) {
      if ($scope.mediaForm.$invalid || $scope.mediaForm.$pristine) {
        return false;
      }
      if (newMedia.type === 'video') {
        newMedia.video_id = newMedia.url.split('/').pop();
        newMedia.video_provider = GalleryService.getVideoProvider(newMedia.url);
      }
      $scope.medias.push(newMedia);
      $scope.newMedia = GalleryService.initMediaProject(newMedia.type);
      $scope.submitted = false;
      $scope.getMediasToShow();
      return $scope.mediaForm.$setPristine();
    };
    return $scope.remove = function(media) {
      var mediaIndex;
      mediaIndex = $scope.medias.indexOf(media);
      if ($scope.coverId === media.id) {
        GalleryService.setCoverId(null);
      }
      if (mediaIndex !== -1) {
        $scope.medias.splice(mediaIndex, 1);
        return $scope.getMediasToShow();
      } else {
        if ($scope.projectsheet.bucket) {
          return BucketFile.one(media.id).remove().then(function() {
            var fileBucketIndex;
            fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media);
            $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1);
            return $scope.getMediasToShow();
          });
        }
      }
    };
  });

  module.controller('GalleryCreationResourceCtrl', function($rootScope, $scope, $filter, GalleryService, ProjectSheet, BucketFile) {
    var user;
    this.$rootScope = $rootScope;
    $scope.config = config;
    user = this.$rootScope.authVars.user;
    $scope.user = user.first_name + ' ' + user.last_name;
    $scope.newMedia = GalleryService.initMediaResource('document', $scope.user);
    $scope.getFilterMedias = function() {
      var medias;
      medias = $scope.projectsheet.bucket ? $scope.medias.concat($scope.projectsheet.bucket.files) : $scope.medias;
      $scope.mediasToShow = $filter('filter')(medias, {
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
    $scope.setUrl = function() {
      var parser;
      if (!$scope.newMedia.is_author) {
        parser = document.createElement('a');
        parser.href = $scope.newMedia.url;
        return $scope.newMedia.author = parser.hostname;
      } else {
        return $scope.newMedia.author = $scope.user;
      }
    };
    $scope.changeTab = function(type) {
      $scope.newMedia = GalleryService.initMediaResource(type, $scope.user);
      $scope.submitted = false;
      if (type === 'experience') {
        return $scope.newMedia.experience = {};
      }
    };
    $scope.addMedia = function(newMedia) {
      if ($scope.mediaForm.$invalid || $scope.mediaForm.$pristine) {
        return false;
      }
      $scope.medias.push(newMedia);
      $scope.newMedia = GalleryService.initMediaResource(newMedia.type, $scope.user);
      $scope.submitted = false;
      return $scope.getFilterMedias();
    };
    return $scope.remove = function(media) {
      var mediaIndex;
      mediaIndex = $scope.medias.indexOf(media);
      if (mediaIndex !== -1) {
        $scope.medias.splice(mediaIndex, 1);
        $scope.getFilterMedias();
      } else {
        if ($scope.projectsheet.bucket) {
          BucketFile.one(media.id).remove().then(function() {
            var fileBucketIndex;
            fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media);
            $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1);
            return $scope.getFilterMedias();
          });
        }
      }
      return $scope.getFilterMedias();
    };
  });

  module.controller('GalleryEditionInstanceCtrl', function($scope, $modalInstance, projectsheet, medias, ProjectService, ProjectSheet, BucketFile, GalleryService) {
    $scope.config = config;
    $scope.projectsheet = projectsheet;
    $scope.hideControls = false;
    $scope.medias = medias;
    $scope.ok = function() {
      var promises;
      if ($scope.medias.length) {
        promises = [];
        angular.forEach($scope.medias, function(media, index) {
          var promise;
          promise = ProjectService.uploadMedia(media, $scope.projectsheet.bucket.id, $scope.projectsheet.id);
          promises.push(promise);
          return promise.then(function(res) {
            if ($scope.coverId === media.id) {
              return ProjectSheet.one($scope.projectsheet.id).patch({
                cover: res.resource_uri
              });
            }
          });
        });
        return Promise.all(promises).then(function() {
          return $modalInstance.close($scope.projectsheet);
        })["catch"](function(err) {
          return console.error(err);
        });
      } else {
        return $modalInstance.close($scope.projectsheet);
      }
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

}).call(this);
