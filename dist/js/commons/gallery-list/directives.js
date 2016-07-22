(function() {
  var module;

  module = angular.module('commons.gallery.directives');

  module.directive('galleryList', function() {
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
      templateUrl: 'views/gallery/gallery-list.directive.html'
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
