module = angular.module("commons.accounts.controllers", ['commons.accounts.services', 'makerscience.base.services'])

module.controller('LoginCtrl', ($scope, $rootScope, $state, $stateParams, $cookies, $http, $auth, User) ->

    $scope.basicLoginError = false

    $scope.authenticate = (provider) ->
        if provider == 'basic'
            $scope.basicLoginError = false

            $rootScope.authVars.username = asmCrypto.SHA1.hex($scope.basicEmail).slice(0,30)
            $rootScope.authVars.password = $scope.basicPassword
            $rootScope.loginService.submit().then((response)->
                if !response.success
                    $scope.basicLoginError = true
            )
        else
            $auth.authenticate(provider).then((response) ->
                if response.data.success
                    $cookies.username = response.data.username
                    $cookies.key = response.data.token
                    $http.defaults.headers.common['Authorization'] = "ApiKey #{response.data.username}:#{response.data.token}"
                    $rootScope.$broadcast('event:auth-loginConfirmed')
                    $state.go($state.current.name, $stateParams)
            )
)

# module.controller('TwitterAuthCtrl', ($scope, $rootScope, $location, $state, $stateParams, $cookies, $http, $auth, User) ->
#     getParams = $location.search()
#     oauth_token = getParams['oauth_token']
#     oauth_verifier = getParams['oauth_verifier']
#
#     User.one().customGET('login/twitter/authenticated', $location.search()).then((response)->
#         console.log(response)
#         if response.success
#             $cookies.username = response.username
#             $cookies.key = response.token
#             $http.defaults.headers.common['Authorization'] = "ApiKey #{response.username}:#{response.token}"
#             $rootScope.$broadcast('event:auth-loginConfirmed')
#             $state.go($state.current.name, $stateParams)
#     )
# )
