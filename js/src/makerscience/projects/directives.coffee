module = angular.module('makerscience.projects.directives', [])

module.directive('projectLight', [ ->
    return {
        restrict: 'E',
        scope: {
            project : "="
        },
        templateUrl: '/views/project/directives/project_light.html',
    }
])
