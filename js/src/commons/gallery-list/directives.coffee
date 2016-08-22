module = angular.module('commons.gallery.directives')

module.directive('galleryList', (GalleryService) ->
    return {
      scope: {
        medias: '='
        edit: '@'
        coverId: '='
        remove: '&remove'
        cover: '&cover'
        uri: '='
      }
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-list.directive.html'
      link: (scope) ->
          scope.isUrlImage = (media) ->
              return GalleryService.isUrlImage(media)
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
