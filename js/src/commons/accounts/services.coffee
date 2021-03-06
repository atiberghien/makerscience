module = angular.module("commons.accounts.services", ['http-auth-interceptor', 'ngCookies', 'restangular'])

module.factory('Groups', (Restangular) ->
        return Restangular.service('account/group')
)

module.factory('User', (Restangular) ->
    return Restangular.service('account/user')
)

module.factory('Profile', (Restangular) ->
    return Restangular.service('account/profile')
)

module.factory('ObjectProfileLink', (Restangular) ->
    return Restangular.service('objectprofilelink')
)

class LoginService
        """
        Login a user
        """
        constructor: (@$rootScope, @baseUrl, @$http, @$state, @Restangular, @$cookies, @authService) ->

                # Add methods to scope
                @$rootScope.submit = this.submit
                @$rootScope.forceLogin = this.forceLogin
                @$rootScope.logout = this.logout

                @$rootScope.authVars =
                        username : "",
                        isAuthenticated: false,
                        loginrequired : false

                # Custom restangular for this login URL
                @loginRestangular = Restangular.withConfig((RestangularConfigurer) ->
                        RestangularConfigurer.setBaseUrl(baseUrl)
                )


                # On login required
                @$rootScope.$on('event:auth-loginRequired', =>
                        @$rootScope.authVars.loginrequired = true
                        console.debug("Login required")
                )

                # On login successful
                @$rootScope.$on('event:auth-loginConfirmed', =>
                        console.debug("Login OK")
                        @$rootScope.authVars.loginrequired = false
                        @$rootScope.authVars.username = @$cookies.username
                        @$rootScope.authVars.isAuthenticated = true
                        @loginRestangular.all('account/user').get(@$cookies.username).then((data)=>
                            console.log("user object", data)
                            @$rootScope.authVars.user = data
                        )
                )

                # set authorization header if already logged in
                if @$cookies.username and @$cookies.key
                        console.debug("Already logged in.")
                        @$http.defaults.headers.common['Authorization'] = "ApiKey #{@$cookies.username}:#{@$cookies.key}"
                        @authService.loginConfirmed()

        forceLogin: =>
                console.debug("forcing login on request")
                @$rootScope.authVars.loginrequired = true

        logout: =>
                @$rootScope.authVars.isAuthenticated = false
                delete @$http.defaults.headers.common['Authorization']
                delete @$cookies['username']
                delete @$cookies['key']
                @$rootScope.authVars.username = ""

        submit: =>
                console.debug('submitting login...')
                @loginRestangular.all('account/user').customPOST(
                        {username: @$rootScope.authVars.username, password: @$rootScope.authVars.password},"login", {}
                        ).then((data) =>
                                if data.success
                                    @$rootScope.authVars.username = data.username
                                    @$cookies.username = data.username
                                    @$cookies.key = data.token
                                    @$http.defaults.headers.common['Authorization'] = "ApiKey #{data.username}:#{data.token}"
                                    @loginRestangular.all('account/user').get(data.username).then((data)=>
                                            console.log("user object", data)
                                            @$rootScope.authVars.user = data
                                            @authService.loginConfirmed()
                                    )
                                    return {success : true}
                                else
                                    return {success : false}

                        , (data) =>
                                @$rootScope.errorMsg = data.reason
                                return {success : false}
                )

module.provider("loginService", ->
        setBaseUrl: (baseUrl) ->
                @baseUrl = baseUrl

        $get: ($rootScope, $http, $state, Restangular, $cookies, authService) ->
                return new LoginService($rootScope, @baseUrl, $http, $state, Restangular, $cookies, authService)
)
