(function() {
  var module;

  module = angular.module("commons.catalog.controllers", ['commons.catalog.services', 'commons.scout.services']);

  module.controller("ProjectListCtrl", function($scope, Project) {
    return $scope.projects = Project.getList().$object;
  });

  module.controller("ProjectSheetCtrl", function($scope, $stateParams, $filter, ProjectSheet, Project, ProjectSheetQuestionAnswer, Bucket, PostalAddress, $http, FileUploader, $modal) {
    this.$http = $http;
    $scope.fetchCoverURL = function(projectsheet) {
      projectsheet.coverURL = "/img/default_project.jpg";
      if ($scope.projectsheet.base_projectsheet.cover) {
        return projectsheet.coverURL = $scope.config.media_uri + $scope.projectsheet.base_projectsheet.cover.thumbnail_url + '?dim=710x390&border=true';
      }
    };
    $scope.updateProjectSheet = function(resourceName, resourceId, fieldName, data) {
      var putData;
      putData = {};
      putData[fieldName] = data;
      switch (resourceName) {
        case 'Project':
          return Project.one(resourceId).patch(putData).then(function(projectResult) {
            $scope.projectsheet.parent.website = projectResult.website;
            return false;
          });
        case 'ProjectSheetQuestionAnswer':
          return ProjectSheetQuestionAnswer.one(resourceId).patch(putData);
        case 'ProjectSheet':
          return ProjectSheet.one(resourceId).patch(putData);
        case 'PostalAddress':
          return PostalAddress.one(resourceId).patch(putData);
      }
    };
    return $scope.openGallery = function(projectsheet) {
      var modalInstance;
      modalInstance = $modal.open({
        templateUrl: '/views/catalog/block/gallery.html',
        controller: 'GalleryEditionInstanceCtrl',
        size: 'lg',
        backdrop: 'static',
        keyboard: false,
        resolve: {
          projectsheet: function() {
            return projectsheet;
          }
        }
      });
      return modalInstance.result.then(function(result) {
        return $scope.$emit('cover-updated');
      });
    };
  });

  module.controller("ProjectSheetCreateCtrl", function($rootScope, $scope, ProjectSheet, Project, ProjectSheetTemplate, ProjectSheetQuestionAnswer, $http, FileUploader, $modal, ObjectProfileLink) {
    this.$http = $http;
    $scope.uploader = new FileUploader({
      url: config.bucket_uri,
      headers: {
        Authorization: this.$http.defaults.headers.common.Authorization
      }
    });
    $scope.coverIndex = null;
    $scope.initProjectSheetCreateCtrl = function(templateSlug) {
      $scope.projectsheet = {
        videos: {}
      };
      $scope.QAItems = [];
      return ProjectSheetTemplate.one().get({
        'slug': templateSlug
      }).then(function(templateResult) {
        var template;
        template = templateResult.objects[0];
        angular.forEach(template.questions, function(question) {
          return $scope.QAItems.push({
            questionLabel: question.text,
            question: question.resource_uri,
            answer: ""
          });
        });
        return $scope.projectsheet.template = template.resource_uri;
      });
    };
    $scope.saveProject = function() {
      if ($scope.projectsheet.project.begin_date === void 0) {
        $scope.projectsheet.project.begin_date = new Date();
      }
      return ProjectSheet.post($scope.projectsheet).then(function(projectsheetResult) {
        angular.forEach($scope.QAItems, function(q_a) {
          q_a.projectsheet = projectsheetResult.resource_uri;
          return ProjectSheetQuestionAnswer.post(q_a);
        });
        return projectsheetResult;
      });
    };
    return $scope.openGallery = function() {
      var modalInstance;
      modalInstance = $modal.open({
        templateUrl: '/views/catalog/block/gallery.html',
        controller: 'GalleryCreationInstanceCtrl',
        size: 'lg',
        resolve: {
          uploader: function() {
            return $scope.uploader;
          }
        }
      });
      return modalInstance.result.then(function(result) {
        $scope.coverIndex = result.coverCandidateQueueIndex;
        return $scope.projectsheet.videos = result.videos;
      }, function() {});
    };
  });

  module.controller('GalleryCreationInstanceCtrl', function($scope, $modalInstance, uploader) {
    $scope.videos = {};
    $scope.coverCandidateQueueIndex = null;
    $scope.uploader = uploader;
    $scope.ok = function() {
      return $modalInstance.close({
        coverCandidateQueueIndex: $scope.coverCandidateQueueIndex,
        videos: $scope.videos
      });
    };
    $scope.cancel = function() {
      $scope.uploader.clearQueue();
      return $modalInstance.dismiss('cancel');
    };
    $scope.isCoverCandidate = function(fileItem) {
      var fileQueueIndex;
      fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem);
      return $scope.coverCandidateQueueIndex !== null && $scope.coverCandidateQueueIndex === fileQueueIndex;
    };
    $scope.toggleCoverCandidate = function(fileItem) {
      if ($scope.isCoverCandidate(fileItem)) {
        return $scope.coverCandidateQueueIndex = null;
      } else {
        return $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem);
      }
    };
    $scope.addVideo = function(newVideoURL) {
      return $scope.videos[newVideoURL] = null;
    };
    return $scope.delVideo = function(videoURL) {
      return delete $scope.videos[videoURL];
    };
  });

  module.controller('GalleryEditionInstanceCtrl', function($scope, $modalInstance, $http, projectsheet, FileUploader, ProjectSheet, BucketFile) {
    this.$http = $http;
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
