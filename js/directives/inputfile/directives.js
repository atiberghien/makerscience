(function() {
  var module;

  module = angular.module('commons.directives.inputfile', []);

  module.directive('inputfile', [
    function() {
      return {
        restrict: 'E',
        scope: {
          setTitle: '&',
          id: '=',
          fileread: '=',
          label: '='
        },
        template: '<input id="{{id}}" class="inputfile" type="file" fileread="fileread" ng-model="fileread" />\n<label for="{{id}}" class="btn btn-primary">{{label}}</label>',
        link: function(scope, element, attributes) {
          return element.bind('change', function(changeEvent) {
            scope.$apply(function() {
              scope.fileread = changeEvent.target.files[0];
            });
            return scope.setTitle(scope.fileread.name);
          });
        }
      };
    }
  ]);

}).call(this);
