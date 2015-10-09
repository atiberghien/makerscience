module = angular.module("makerscience.profile.services", ['commons.accounts.services'])

# Restangular-based Services
module.factory('MakerScienceProfile', (Restangular) ->
    return Restangular.service('makerscience/profile')
)
module.factory('MakerScienceProfileLight', (Restangular) ->
    return Restangular.service('makerscience/profilelight')
)

module.factory('MakerScienceProfileTaggedItem', (Restangular) ->
    return Restangular.service('makerscience/profiletaggeditem')
)

# Specific services
class CurrentMakerScienceProfileService
    constructor : ($rootScope, $modal, MakerScienceProfile) ->

        $rootScope.$watch('authVars.user', (newValue, oldValue) ->
            if newValue != oldValue
                MakerScienceProfile.one().get({parent__user__id : $rootScope.authVars.user.id}).then((profileResult)->
                    $rootScope.currentMakerScienceProfile = profileResult.objects[0]
                )
        )

        $rootScope.openSignupPopup = ()->
            modalInstance = $modal.open(
                templateUrl: '/views/base/signupModal.html',
                controller: 'SignupPopupCtrl'
            )

        $rootScope.openSigninPopup = () ->
            modalInstance = $modal.open(
                templateUrl: '/views/base/signinModal.html',
                controller: 'SigninPopupCtrl',
            )

        $rootScope.$watch('authVars.loginrequired', (newValue, oldValue) ->
            console.log('loginRequired', newValue, oldValue)
            if newValue == true
                $rootScope.openSigninPopup()

        )

module.factory('CurrentMakerScienceProfileService', ($rootScope, $modal, MakerScienceProfile) ->
    return new CurrentMakerScienceProfileService($rootScope, $modal, MakerScienceProfile)
)


module.controller('SignupPopupCtrl', ($scope, $rootScope, $modalInstance, $state, User) ->
    """
    Controller bound to openSignupPopup method of CurrentMakerScienceProfile service
    """
    $scope.first_name = null
    $scope.last_name = null
    $scope.email = null
    $scope.password = null
    $scope.password2 = null

    $scope.emailError = false
    $scope.passwordError = false

    $scope.register = () ->
        $scope.emailError = false
        $scope.passwordError = false

        if $scope.password != null && $scope.password != $scope.password2
            $scope.passwordError = true

        User.one().get({email : $scope.email}).then((userResults)->
            console.log(userResults.objects.length)
            if userResults.objects.length > 0
                $scope.emailError = true
        )

        if $scope.emailError || $scope.passwordError
            return

        usernameHash = asmCrypto.SHA1.hex($scope.username).slice(0,30)
        userData =
            first_name :$scope.first_name
            last_name : $scope.last_name
            username : usernameHash
            email : $scope.email
            password : $scope.password
        User.post(userData).then((userResult) ->
            $rootScope.authVars.username = usernameHash
            $rootScope.authVars.password = $scope.password
            $rootScope.loginService.submit()
        )

    $rootScope.$watch('authVars.isAuthenticated', (newValue, oldValue) ->
        if newValue == true and oldValue== false
            $modalInstance.close()
    )
)

module.controller('SigninPopupCtrl', ($scope, $rootScope, $modalInstance) ->
    $rootScope.$watch('authVars.isAuthenticated', (newValue, oldValue) ->
        if newValue == true and oldValue== false
            $modalInstance.close()
    )
)
