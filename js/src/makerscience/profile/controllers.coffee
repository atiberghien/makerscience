module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.init = (limit) ->
        params = {}
        if limit
            params['limit'] = limit
        $scope.profiles = MakerScienceProfile.getList(params).$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, MakerScienceProfile) ->

    MakerScienceProfile.one($stateParams.id).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult
    )
)
