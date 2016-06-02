(function() {
  var LoginService, module,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  module = angular.module("commons.accounts.services", ['http-auth-interceptor', 'ngCookies', 'restangular']);

  module.factory('Groups', function(Restangular) {
    return Restangular.service('account/group');
  });

  module.factory('User', function(Restangular) {
    return Restangular.service('account/user');
  });

  module.factory('Profile', function(Restangular) {
    return Restangular.service('account/profile');
  });

  module.factory('ObjectProfileLink', function(Restangular) {
    return Restangular.service('objectprofilelink');
  });

  LoginService = (function() {
    "Login a user";
    function LoginService($rootScope, baseUrl, $http, $state, Restangular, $cookies, authService) {
      this.$rootScope = $rootScope;
      this.baseUrl = baseUrl;
      this.$http = $http;
      this.$state = $state;
      this.Restangular = Restangular;
      this.$cookies = $cookies;
      this.authService = authService;
      this.submit = __bind(this.submit, this);
      this.logout = __bind(this.logout, this);
      this.forceLogin = __bind(this.forceLogin, this);
      this.$rootScope.submit = this.submit;
      this.$rootScope.forceLogin = this.forceLogin;
      this.$rootScope.logout = this.logout;
      this.$rootScope.authVars = {
        username: "",
        isAuthenticated: false,
        loginrequired: false
      };
      this.loginRestangular = Restangular.withConfig(function(RestangularConfigurer) {
        return RestangularConfigurer.setBaseUrl(baseUrl);
      });
      this.$rootScope.$on('event:auth-loginRequired', (function(_this) {
        return function() {
          _this.$rootScope.authVars.loginrequired = true;
          return console.debug("Login required");
        };
      })(this));
      this.$rootScope.$on('event:auth-loginConfirmed', (function(_this) {
        return function() {
          console.debug("Login OK");
          _this.$rootScope.authVars.loginrequired = false;
          _this.$rootScope.authVars.username = _this.$cookies.username;
          _this.$rootScope.authVars.isAuthenticated = true;
          return _this.loginRestangular.all('account/user').get(_this.$cookies.username).then(function(data) {
            console.log("user object", data);
            return _this.$rootScope.authVars.user = data;
          });
        };
      })(this));
      if (this.$cookies.username && this.$cookies.key) {
        console.debug("Already logged in.");
        this.$http.defaults.headers.common['Authorization'] = "ApiKey " + this.$cookies.username + ":" + this.$cookies.key;
        this.authService.loginConfirmed();
      }
    }

    LoginService.prototype.forceLogin = function() {
      console.debug("forcing login on request");
      return this.$rootScope.authVars.loginrequired = true;
    };

    LoginService.prototype.logout = function() {
      this.$rootScope.authVars.isAuthenticated = false;
      delete this.$http.defaults.headers.common['Authorization'];
      delete this.$cookies['username'];
      delete this.$cookies['key'];
      return this.$rootScope.authVars.username = "";
    };

    LoginService.prototype.submit = function() {
      console.debug('submitting login...');
      return this.loginRestangular.all('account/user').customPOST({
        username: this.$rootScope.authVars.username,
        password: this.$rootScope.authVars.password
      }, "login", {}).then((function(_this) {
        return function(data) {
          if (data.success) {
            _this.$rootScope.authVars.username = data.username;
            _this.$cookies.username = data.username;
            _this.$cookies.key = data.token;
            _this.$http.defaults.headers.common['Authorization'] = "ApiKey " + data.username + ":" + data.token;
            _this.loginRestangular.all('account/user').get(data.username).then(function(data) {
              console.log("user object", data);
              _this.$rootScope.authVars.user = data;
              return _this.authService.loginConfirmed();
            });
            return {
              success: true
            };
          } else {
            return {
              success: false
            };
          }
        };
      })(this), (function(_this) {
        return function(data) {
          _this.$rootScope.errorMsg = data.reason;
          return {
            success: false
          };
        };
      })(this));
    };

    return LoginService;

  })();

  module.provider("loginService", function() {
    return {
      setBaseUrl: function(baseUrl) {
        return this.baseUrl = baseUrl;
      },
      $get: function($rootScope, $http, $state, Restangular, $cookies, authService) {
        return new LoginService($rootScope, this.baseUrl, $http, $state, Restangular, $cookies, authService);
      }
    };
  });

}).call(this);
