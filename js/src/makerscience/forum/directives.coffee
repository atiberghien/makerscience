module = angular.module('makerscience.forum.directives', [])

module.directive('bestContributors', [ ->
    return {
        restrict: 'E',
        scope: {},
        templateUrl: 'views/forum/directives/best_contributors.html',
        controller: ($scope, ObjectProfileLink) ->
            ObjectProfileLink.one().customGET('post/best', {level:[30,31,32], limit: 5}).then((profileResults) ->
                $scope.bestContributorProfiles = profileResults.objects
            )
        ,
    }
])

module.directive('threadLight', [ ->
    return {
        restrict: 'E',
        scope: {
            post : "="
            threadStyle : '@'
        },
        templateUrl: '/views/forum/directives/thread_light.html',
        controller: ($scope) ->
            if !$scope.threadFormat
                $scope.threadStyle = ''
    }
])
