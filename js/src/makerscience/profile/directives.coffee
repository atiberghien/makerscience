module = angular.module("makerscience.profile.directives", [])

module.directive('mksProfileCard', [ ->
    return {
        restrict: 'E',
        scope: {
            profile : "=" #baseProfile
            avatarSize : "@"
            avatarExtraClass : "@"
            textColor : "@"
        },
        template: '''
            <a class="avatar-link" ui-sref="profile.detail({slug:slug})" style="color:{{textColor}}">
                <avatar profile="profile" size="{{avatarSize}}" extra-class="{{avatarExtraClass}}"></avatar>
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
