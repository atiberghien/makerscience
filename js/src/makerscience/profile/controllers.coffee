module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.profiles = MakerScienceProfile.getList().$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, Users, Profile, MakerScienceProfile, PostalAddress) ->

    $scope.init = (profileID) ->
        MakerScienceProfile.one(profileID).get().then((makerScienceProfileResult) ->
            $scope.profile = makerScienceProfileResult
            baseProfileID = getObjectIdFromURI(makerScienceProfileResult.parent)
            Profile.one(baseProfileID).get().then((profileResult)->
                $scope.profile.parent = profileResult
                Users.one(profileResult.username).get().then((userResult)->
                    $scope.profile.parent.user = userResult
                    if $scope.profile.location
                        postalAddressId = getObjectIdFromURI($scope.profile.location)
                        $scope.profile.location = PostalAddress.one(postalAddressId).get().$object
                )
            )
        )

    if $stateParams.id
        $scope.init($stateParams.id)
)
