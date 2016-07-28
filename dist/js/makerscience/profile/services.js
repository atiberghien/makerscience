(function() {
  var CurrentMakerScienceProfileService, module;

  module = angular.module("makerscience.profile.services", ['commons.accounts.services']);

  module.factory('MakerScienceProfile', function(Restangular) {
    return Restangular.service('makerscience/profile');
  });

  module.factory('MakerScienceProfileLight', function(Restangular) {
    return Restangular.service('makerscience/profilelight');
  });

  module.factory('MakerScienceProfileTaggedItem', function(Restangular) {
    return Restangular.service('makerscience/profiletaggeditem');
  });

  CurrentMakerScienceProfileService = (function() {
    function CurrentMakerScienceProfileService($rootScope, $modal, $state, MakerScienceProfile) {
      $rootScope.$watch('authVars.user', function(newValue, oldValue) {
        if (newValue !== oldValue) {
          return MakerScienceProfile.one().get({
            parent__user__id: $rootScope.authVars.user.id
          }).then(function(profileResult) {
            return $rootScope.currentMakerScienceProfile = profileResult.objects[0];
          });
        }
      });
      $rootScope.openSignupPopup = function() {
        var modalInstance;
        return modalInstance = $modal.open({
          templateUrl: '/views/base/signupModal.html',
          controller: 'SignupPopupCtrl'
        });
      };
      $rootScope.openSigninPopup = function() {
        var modalInstance;
        modalInstance = $modal.open({
          templateUrl: '/views/base/signinModal.html',
          controller: 'SigninPopupCtrl'
        });
        return modalInstance.result.then(function() {
          return $rootScope.authVars.loginrequired = false;
        }, function() {
          $rootScope.authVars.loginrequired = false;
          if ($rootScope.beforeLoginState !== null && $rootScope.beforeLoginState.name) {
            return $state.transitionTo($rootScope.beforeLoginState.name);
          } else {
            return $state.transitionTo('home');
          }
        });
      };
      $rootScope.$watch('authVars.loginrequired', function(newValue, oldValue) {
        console.log('loginRequired', newValue, oldValue);
        if (newValue === true) {
          return $rootScope.openSigninPopup();
        }
      });
    }

    return CurrentMakerScienceProfileService;

  })();

  module.factory('CurrentMakerScienceProfileService', function($rootScope, $modal, $state, MakerScienceProfile) {
    return new CurrentMakerScienceProfileService($rootScope, $modal, $state, MakerScienceProfile);
  });

  module.controller('SignupPopupCtrl', function($scope, $rootScope, $modalInstance, $state, User) {
    "Controller bound to openSignupPopup method of CurrentMakerScienceProfile service";
    $scope.first_name = null;
    $scope.last_name = null;
    $scope.email = null;
    $scope.password = null;
    $scope.password2 = null;
    $scope.emailError = false;
    $scope.passwordError = false;
    $scope.register = function() {
      var userData, usernameHash;
      $scope.emailError = false;
      $scope.passwordError = false;
      if ($scope.password !== null && $scope.password !== $scope.password2) {
        $scope.passwordError = true;
      }
      User.one().get({
        email: $scope.email
      }).then(function(userResults) {
        if (userResults.objects.length > 0) {
          return $scope.emailError = true;
        }
      });
      if ($scope.emailError || $scope.passwordError) {
        return;
      }
      usernameHash = asmCrypto.SHA1.hex($scope.email).slice(0, 30);
      userData = {
        first_name: $scope.first_name,
        last_name: $scope.last_name,
        username: usernameHash,
        email: $scope.email,
        password: $scope.password
      };
      return User.post(userData).then(function(userResult) {
        $rootScope.authVars.username = usernameHash;
        $rootScope.authVars.password = $scope.password;
        return $rootScope.loginService.submit();
      });
    };
    $scope.viewCGU = function() {
      $modalInstance.close();
      return $state.go('cgu');
    };
    return $rootScope.$watch('authVars.isAuthenticated', function(newValue, oldValue) {
      if (newValue === true && oldValue === false) {
        return $modalInstance.close();
      }
    });
  });

  module.controller('SigninPopupCtrl', function($scope, $rootScope, $modalInstance) {
    return $rootScope.$watch('authVars.isAuthenticated', function(newValue, oldValue) {
      if (newValue === true && oldValue === false) {
        return $modalInstance.close();
      }
    });
  });

}).call(this);
