module = angular.module('makerscience.forum.directives', [])

module.directive('bestContributors', [ ->
    return {
        restrict: 'E',
        scope: {},
        templateUrl: 'views/forum/block/best_contributors.html',
        controller: ($scope, ObjectProfileLink) ->
            ObjectProfileLink.one().customGET('post/best', {level:[30,31,32], limit: 5}).then((profileResults) ->
                $scope.bestContributorProfiles = profileResults.objects
            )
        ,
    }
])
