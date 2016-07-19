(function() {
  var module;

  module = angular.module('commons.directives.thumb', []);

  module.directive('ngThumb', [
    '$window', 'GalleryService', function($window, GalleryService) {
      var helper;
      helper = {
        support: !!($window.FileReader && $window.CanvasRenderingContext2D),
        isFile: function(item) {
          return angular.isObject(item) && item instanceof $window.File;
        },
        isImage: function(file) {
          return GalleryService.isTypeImage(file.type);
        }
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
            if (!helper.isFile(scope.params.file)) {
              return;
            }
            if (!helper.isImage(scope.params.file)) {
              return;
            }
            return reader.readAsDataURL(scope.params.file);
          });
          return element.bind('change', function(changeEvent) {
            if (!helper.isFile(scope.params.file)) {
              return;
            }
            if (!helper.isImage(scope.params.file)) {
              return;
            }
            return reader.readAsDataURL(scope.params.file);
          });
        }
      };
    }
  ]);

}).call(this);
