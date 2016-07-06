(function() {
  var module;

  module = angular.module('commons.directives.thumb', []);

  module.directive('ngThumb', [
    '$window', function($window) {
      var helper;
      helper = {
        support: !!($window.FileReader && $window.CanvasRenderingContext2D)
      };
      return {
        restrict: 'E',
        scope: {
          params: '='
        },
        template: '<canvas/>',
        link: function(scope, element, attributes) {
          var canvas, reader;
          if (!helper.support) {
            return;
          }
          canvas = element.find('canvas');
          reader = new FileReader();
          reader.onload = function(event) {
            var img;
            img = new Image();
            img.onload = function() {
              var height, width;
              width = scope.params.width || this.width / this.height * scope.params.height;
              height = scope.params.height || this.height / this.width * scope.params.width;
              canvas.attr({
                width: width,
                height: height
              });
              return canvas[0].getContext('2d').drawImage(this, 0, 0, width, height);
            };
            return img.src = event.target.result;
          };
          scope.$watch('params', function() {
            return reader.readAsDataURL(scope.params.file);
          });
          return element.bind('change', function(changeEvent) {
            return reader.readAsDataURL(scope.params.file);
          });
        }
      };
    }
  ]);

}).call(this);
