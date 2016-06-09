module = angular.module('commons.community.directives', [])

module.directive('communityProject', [ ->
    return {
        scope: {
          objectTypeName: '@'
          objectId: '='
        }
        restrict: 'E'
        templateUrl: 'views/block/community_project.html'
        controller: 'CommunityCtrl'
    }
])
