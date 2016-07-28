(function() {
  var module;

  module = angular.module('commons.gallery.directives');

  module.directive('galleryList', function(GalleryService) {
    return {
      scope: {
        medias: '=',
        edit: '@',
        coverId: '=',
        remove: '&remove',
        cover: '&cover',
        uri: '='
      },
      restrict: 'E',
      templateUrl: 'views/gallery/gallery-list.directive.html',
      link: function(scope) {
        return scope.isUrl = function(src) {
          return GalleryService.isUrlImage(src);
        };
      }
    };
  });

  module.directive('galleryExperiencesList', function() {
    return {
      scope: {
        medias: '=',
        edit: '@',
        remove: '&remove'
      },
      restrict: 'E',
      templateUrl: 'views/gallery/gallery-experiences-list.directive.html'
    };
  });

}).call(this);
