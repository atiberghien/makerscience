module = angular.module('commons.directives.socialshare', [])

module.directive('socialshare', [ ->
    return {
      restrict: 'E'
      scope: true
      replace: true
      templateUrl: '/views/block/social_share.html'
    }

])
