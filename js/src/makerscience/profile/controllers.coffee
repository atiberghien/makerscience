module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.profiles = MakerScienceProfile.getList().$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, Users, Profile, MakerScienceProfile, PostalAddress) ->

    MakerScienceProfile.one($stateParams.id).get().then((makerScienceProfileResult) ->
        $scope.profile = makerScienceProfileResult
    )
)
