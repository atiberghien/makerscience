module = angular.module('commons.gallery.directives', [])

module.directive('galleryProject', (BucketFile, ProjectSheet) ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-project.directive.html',
      controller: 'GalleryCreationInstanceCtrl'
    }
)

module.directive('galleryResource', (BucketFile, ProjectSheet) ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-resource.directive.html',
      controller: 'GalleryCreationInstanceCtrl'
    }
)
