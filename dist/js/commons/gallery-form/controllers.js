(function() {
  var module;

  module = angular.module('commons.gallery.controllers', []);

  module.controller('GalleryCreationInstanceCtrl', function($scope, ProjectSheet) {
    $scope.currentType = null;
    $scope.setTitle = function(title) {
      return $scope.$apply(function() {
        $scope.newMedia.title = title;
      });
    };
    $scope.tabSelect = function(type) {
      $scope.newMedia = {
        title: '',
        type: type
      };
      return $scope.currentType = type;
    };
    $scope.config = config;
    $scope.coverCandidateQueueIndex = null;
    $scope.uploader.onAfterAddingFile = function(item) {
      item.file.name = $scope.newMedia.title;
      return $scope.newMedia = {
        type: $scope.currentType
      };
    };
    $scope.addMedia = function(newMedia) {
      var uniqueId;
      if ($scope.mediaForm.$invalid || (!$scope.newMedia.url && !$scope.newMedia.file)) {
        console.log('invalid form');
        return false;
      }
      uniqueId = _.uniqueId();
      if (newMedia.file) {
        newMedia.description;
        $scope.newMedia = newMedia;
        newMedia.bucket = true;
        $scope.uploader.addToQueue(newMedia.file);
      } else {
        newMedia.bucket = false;
      }
      $scope.projectsheet.medias[uniqueId] = newMedia;
      return $scope.submitted = false;
    };
    $scope.cancel = function() {
      return $scope.uploader.clearQueue();
    };
    $scope.isCoverCandidate = function(fileIndex) {
      return $scope.coverCandidateQueueIndex !== null && $scope.coverCandidateQueueIndex === fileIndex;
    };
    $scope.toggleCoverCandidate = function(fileIndex) {
      if ($scope.isCoverCandidate(fileIndex)) {
        return $scope.coverCandidateQueueIndex = null;
      } else {
        return $scope.coverCandidateQueueIndex = fileIndex;
      }
    };
    return $scope.delVideo = function(videoURL) {
      return delete $scope.videos[videoURL];
    };
  });

  module.controller('GalleryEditionInstanceCtrl', function($scope, $modalInstance, $http, projectsheet, FileUploader, ProjectSheet, BucketFile) {
    this.$http = $http;
    $scope.newMedia = {};
    $scope.projectsheet = projectsheet;
    $scope.coverCandidateQueueIndex = null;
    $scope.hideControls = false;
    $scope.uploader = new FileUploader({
      url: config.bucket_uri,
      headers: {
        Authorization: this.$http.defaults.headers.common.Authorization
      }
    });
    if (!$scope.projectsheet.videos) {
      $scope.projectsheet.videos = {};
    }
    $scope.videos = $scope.projectsheet.videos;
    $scope.uploader.onBeforeUploadItem = function(item) {
      item.formData.push({
        bucket: $scope.projectsheet.bucket.id
      });
      return item.headers = {
        Authorization: $scope.uploader.headers["Authorization"]
      };
    };
    $scope.tmpBucketFiles = [];
    $scope.tmpNewCover = null;
    $scope.uploader.onCompleteItem = function(fileItem, response, status, headers) {
      if ($scope.isCoverCandidate(fileItem)) {
        $scope.tmpNewCover = response;
      }
      return $scope.tmpBucketFiles.push(response);
    };
    $scope.uploader.onCompleteAll = function() {
      if ($scope.tmpNewCover) {
        $scope.toggleCover($scope.tmpNewCover).then(function() {
          return angular.forEach($scope.tmpBucketFiles, function(file) {
            return $scope.projectsheet.bucket.files.push(file);
          });
        });
      } else {
        angular.forEach($scope.tmpBucketFiles, function(file) {
          return $scope.projectsheet.bucket.files.push(file);
        });
      }
      return $modalInstance.close();
    };
    $scope.ok = function() {
      ProjectSheet.one($scope.projectsheet.id).patch({
        videos: $scope.projectsheet.videos
      });
      if ($scope.uploader.queue.length > 0) {
        return $scope.uploader.uploadAll();
      } else {
        return $scope.uploader.onCompleteAll();
      }
    };
    $scope.cancel = function() {
      $scope.uploader.clearQueue();
      return $modalInstance.dismiss('cancel');
    };
    $scope.removePicture = function(file) {
      if ($scope.isCover(file)) {
        $scope.toggleCover(file);
      }
      return BucketFile.one(file.id).remove().then(function() {
        var fileBucketIndex;
        fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(file);
        return $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1);
      });
    };
    $scope.isCoverCandidate = function(fileItem) {
      var fileQueueIndex;
      fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem);
      return $scope.coverCandidateQueueIndex !== null && $scope.coverCandidateQueueIndex === fileQueueIndex;
    };
    $scope.isCover = function(file) {
      return $scope.projectsheet.cover !== null && $scope.projectsheet.cover.id === file.id;
    };
    $scope.toggleCoverCandidate = function(fileItem) {
      if ($scope.isCoverCandidate(fileItem)) {
        return $scope.coverCandidateQueueIndex = null;
      } else {
        return $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem);
      }
    };
    $scope.toggleCover = function(file) {
      if ($scope.isCover(file)) {
        $scope.projectsheet.cover = null;
        return ProjectSheet.one($scope.projectsheet.id).patch({
          cover: null
        });
      } else {
        $scope.projectsheet.cover = file;
        return ProjectSheet.one($scope.projectsheet.id).patch({
          cover: file.resource_uri
        });
      }
    };
    $scope.addVideo = function(newVideoURL) {
      $scope.projectsheet.videos[newVideoURL] = null;
      $scope.videos[newVideoURL] = null;
      return ProjectSheet.one($scope.projectsheet.id).patch({
        videos: $scope.projectsheet.videos
      });
    };
    return $scope.delVideo = function(videoURL) {
      delete $scope.projectsheet.videos[videoURL];
      delete $scope.videos[videoURL];
      return ProjectSheet.one($scope.projectsheet.id).patch({
        videos: $scope.projectsheet.videos
      });
    };
  });

}).call(this);
