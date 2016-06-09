module = angular.module('commons.community.directives', [])

module.directive('communityProject', [ ->
    return {
        scope: {
          objectTypeName: '@'
          objectId: '='
        }
        restrict: 'E'
        templateUrl: 'views/block/community_project.directive.html'
        controller: 'CommunityCtrl'
    }
])

module.directive('communityResource', [ ->
    return {
        scope: {
          objectTypeName: '@'
          objectId: '='
        }
        restrict: 'E'
        templateUrl: 'views/block/community_resource.directive.html'
        controller: 'CommunityCtrl'
    }
])
