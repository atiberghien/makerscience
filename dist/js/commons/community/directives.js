(function() {
  var module;

  module = angular.module('commons.community.directives', []);

  module.directive('communityProject', [
    function() {
      return {
        scope: {
          objectTypeName: '@',
          objectId: '='
        },
        restrict: 'E',
        templateUrl: 'views/block/community_project.directive.html',
        controller: 'CommunityCtrl'
      };
    }
  ]);

  module.directive('communityResource', [
    function() {
      return {
        scope: {
          objectTypeName: '@',
          objectId: '='
        },
        restrict: 'E',
        templateUrl: 'views/block/community_resource.directive.html',
        controller: 'CommunityCtrl'
      };
    }
  ]);

}).call(this);
