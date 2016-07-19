(function() {
  var module;

  module = angular.module('commons.directives.cover', []);

  module.directive('coverButton', [
    function() {
      return {
        restrict: 'E',
        scope: {
          media: '=',
          coverId: '=',
          toggle: '&'
        },
        template: '<button type="button" class="btn btn-xs" ng-click="toggleCover(media)">\n    <span ng-hide="coverId === media.id" class="glyphicon glyphicon-star"></span>\n    <span ng-show="coverId === media.id" class="glyphicon glyphicon-star" style="color:orange"></span>\n    Choisir l\'image en une\n</button>',
        link: function(scope, el, attrs) {
          return scope.toggleCover = function(media) {
            return scope.toggle(media);
          };
        }
      };
    }
  ]);

}).call(this);
