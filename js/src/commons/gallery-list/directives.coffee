module = angular.module('commons.gallery.directives')

module.directive('galleryList', () ->
    return {
      scope: {
        medias: '='
        edit: '@'
        coverId: '='
        remove: '&remove'
        cover: '&cover'
      }
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-list.directive.html'
    }
)

module.directive('galleryExperiencesList', () ->
    return {
      scope: {
        medias: '='
        edit: '@'
        remove: '&remove'
      }
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-experiences-list.directive.html'
    }
)
