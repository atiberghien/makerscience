module = angular.module('commons.gallery.directives', [])

module.directive('galleryProject', () ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-project.directive.html',
      controller: 'GalleryCreationProjectCtrl'
    }
)

module.directive('galleryResource', () ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-resource.directive.html',
      controller: 'GalleryCreationResourceCtrl'
    }
)
