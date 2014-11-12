module = angular.module("makerscience.base.controllers", [])

module.controller('LoginModalCtrl', ($scope, $modal) ->
    $scope.$watch('authVars.loginrequired', (newValue, oldValue) ->
        if oldValue == false && newValue == true
            modalInstance = $modal.open({
                templateUrl: 'loginModalContent.html',
            })
    )
)
