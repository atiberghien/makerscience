(function() {
  var module;

  module = angular.module("commons.accounts.controllers", ['commons.accounts.services', 'makerscience.base.services']);

  module.controller('LoginCtrl', function($scope, $rootScope, $state, $stateParams, $cookies, $http, $auth, User) {
    $scope.basicLoginError = false;
    return $scope.authenticate = function(provider) {
      if (provider === 'basic') {
        $scope.basicLoginError = false;
        $rootScope.authVars.username = asmCrypto.SHA1.hex($scope.basicEmail).slice(0, 30);
        $rootScope.authVars.password = $scope.basicPassword;
        return $rootScope.loginService.submit().then(function(response) {
          if (!response.success) {
            return $scope.basicLoginError = true;
          }
        });
      } else {
        return $auth.authenticate(provider).then(function(response) {
          if (response.data.success) {
            $cookies.username = response.data.username;
            $cookies.key = response.data.token;
            $http.defaults.headers.common['Authorization'] = "ApiKey " + response.data.username + ":" + response.data.token;
            $rootScope.$broadcast('event:auth-loginConfirmed');
            return $state.go($state.current.name, $stateParams);
          }
        });
      }
    };
  });

}).call(this);
