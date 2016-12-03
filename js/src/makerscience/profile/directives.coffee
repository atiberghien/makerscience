module = angular.module("makerscience.profile.directives", [])

module.directive('mksProfileCard', [ ->
    return {
        restrict: 'E',
        scope: {
            profile : "=" #baseProfile
        },
        template: '''
            <a ui-sref="profile.detail({slug:slug})">
                <avatar profile="profile" size="52"></avatar>
                {{profile.user.first_name}} <strong>{{profile.user.last_name}}</strong>
            </a>
        ''',
        controller: ($scope, MakerScienceProfile) ->
            MakerScienceProfile.one().get({parent__id: $scope.profile.id}).then((profileResults) ->
                $scope.slug = profileResults.objects[0].slug
            )
        ,

    }
])
