module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.profiles = MakerScienceProfile.getList().$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, Users, Profile, MakerScienceProfile) ->
    MakerScienceProfile.one($stateParams.id).get().then((makerScienceProfileResult) ->
        $scope.profile = makerScienceProfileResult
        baseProfileID = getObjectIdFromURI(makerScienceProfileResult.parent)
        Profile.one(baseProfileID).get().then((profileResult)->
            $scope.profile.parent = profileResult
            Users.one(profileResult.username).get().then((userResult)->
                $scope.profile.parent.user = userResult
            )
        )
    )
)
