module = angular.module('commons.gallery.directives')

module.directive('galleryList', () ->
    return {
      scope: {
        medias: '='
        edit: '@'
        remove: '&remove'
      }
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-list.directive.html'
    }
)
