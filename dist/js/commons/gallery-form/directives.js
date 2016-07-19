(function() {
  var module;

  module = angular.module('commons.gallery.directives', []);

  module.directive('galleryForm', function(BucketFile, ProjectSheet) {
    return {
      scope: true,
      restrict: 'E',
      templateUrl: 'views/gallery-form/gallery-form.directive.html',
      controller: 'GalleryCreationInstanceCtrl'
    };
  });

}).call(this);
