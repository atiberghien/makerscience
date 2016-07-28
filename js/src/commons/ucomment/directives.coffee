module = angular.module('commons.ucomment.directives', [])

module.directive('comments', [ ->
    return {
        scope: {
          objectTypeName: '@'
          objectId: '='
        }
        restrict: 'E'
        templateUrl: 'views/block/comments.directive.html'
        controller: 'CommentCtrl'
    }
])
