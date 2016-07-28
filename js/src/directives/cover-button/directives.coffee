module = angular.module('commons.directives.cover', [])

module.directive('coverButton', [ ->
    return {
      restrict: 'E'
      scope: {
        media: '='
        coverId: '='
        toggle: '&'
      }
      template: '''
        <button type="button" class="btn btn-xs" ng-click="toggleCover(media)">
            <span ng-hide="coverId === media.id" class="glyphicon glyphicon-star"></span>
            <span ng-show="coverId === media.id" class="glyphicon glyphicon-star" style="color:orange"></span>
            Choisir l'image en une
        </button>
      '''
      link: (scope, el, attrs) ->

          scope.toggleCover = (media) ->
              scope.toggle(media)
    }

])
