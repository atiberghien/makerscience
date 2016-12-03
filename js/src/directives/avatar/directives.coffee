module = angular.module('commons.directives.avatar', [])

module.directive('avatar', [ ->
    return {
      restrict: 'E'
      scope: {
          size : "@"
          profile : "="
      }
      template: '''
        <span class="avatar avatar{{size}} no-float">
            <img ng-show="profile.parent.avatar" src="{{profile.parent.avatar}}" class="profile img-circle">
            <img ng-show="profile.avatar" src="{{profile.avatar}}" class="profile img-circle">
            <img ng-hide="profile.parent.avatar || profile.avatar" src="/img/avatar.png" class="profile img-circle">
        </span>
      '''
    }
])
