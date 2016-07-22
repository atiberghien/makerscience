(function() {
  var module;

  module = angular.module('commons.gallery.directives', []);

  module.directive('galleryProject', function() {
    return {
      scope: true,
      restrict: 'E',
      templateUrl: 'views/gallery/gallery-project.directive.html',
      controller: 'GalleryCreationProjectCtrl'
    };
  });

  module.directive('galleryResource', function() {
    return {
      scope: true,
      restrict: 'E',
      templateUrl: 'views/gallery/gallery-resource.directive.html',
      controller: 'GalleryCreationResourceCtrl'
    };
  });

  module.directive('checkForm', function(GalleryService) {
    return {
      require: "form",
      restrict: 'A',
      link: function(scope, el) {
        var check;
        check = function() {
          if (scope.newMedia.url) {
            scope.mediaForm.$setValidity('mediaDefine', true);
            if (scope.mediaForm.imageUrl) {
              scope.mediaForm.imageUrl.$setValidity('format', true);
            }
            if (scope.mediaForm.documentUrl) {
              scope.mediaForm.documentUrl.$setValidity('format', true);
            }
            if (scope.mediaForm.videoUrl) {
              scope.mediaForm.videoUrl.$setValidity('format', true);
            }
            switch (scope.newMedia.type) {
              case 'image':
                return scope.mediaForm.imageUrl.$setValidity('format', GalleryService.isUrlImage(scope.newMedia.url));
              case 'document':
                return scope.mediaForm.documentUrl.$setValidity('format', GalleryService.isUrlDocument(scope.newMedia.url));
              case 'video':
                return scope.mediaForm.videoUrl.$setValidity('format', GalleryService.isUrlVideo(scope.newMedia.url));
              case 'link':
                return scope.mediaForm.mediaUrl.$setValidity('format', GalleryService.isUrl(scope.newMedia.url));
            }
          } else if (scope.newMedia.file) {
            scope.mediaForm.$setValidity('mediaDefine', true);
            scope.mediaForm.$setValidity('imageFileFormat', true);
            scope.mediaForm.$setValidity('documentFileFormat', true);
            switch (scope.newMedia.type) {
              case 'image':
                return scope.mediaForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type));
              case 'document':
                return scope.mediaForm.$setValidity('documentFileFormat', GalleryService.isTypeDocument(scope.newMedia.file.type));
            }
          } else {
            return scope.mediaForm.$setValidity('mediaDefine', false);
          }
        };
        scope.mediaForm.$setValidity('mediaDefine', false);
        el.bind('change', function() {
          return scope.$apply(function() {
            return check();
          });
        });
        return scope.setTitle = function(title) {
          return scope.$apply(function() {
            scope.mediaForm.$setDirty();
            scope.newMedia.title = title;
          });
        };
      }
    };
  });

}).call(this);
