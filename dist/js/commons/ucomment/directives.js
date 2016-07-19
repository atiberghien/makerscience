(function() {
  var module;

  module = angular.module('commons.ucomment.directives', []);

  module.directive('comments', [
    function() {
      return {
        scope: {
          objectTypeName: '@',
          objectId: '='
        },
        restrict: 'E',
        templateUrl: 'views/block/comments.directive.html',
        controller: 'CommentCtrl'
      };
    }
  ]);

}).call(this);
