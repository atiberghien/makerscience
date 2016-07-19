(function() {
  var module;

  module = angular.module('commons.directives.reportabuse', []);

  module.directive('reportAbuseButton', function($modal) {
    return {
      restrict: 'E',
      scope: true,
      template: '<a class="report-abuse" ng-click="showReportAbusePopup(location.protocol() + \'://\' + location.host() + \'\' + location.path())">\n    <i class="fa fa-exclamation-circle"></i> Signaler un contenu abusif\n</a>',
      link: function(scope, element, attributes) {
        return scope.showReportAbusePopup = function(currentLocation) {
          var modalInstance;
          return modalInstance = $modal.open({
            templateUrl: '/views/base/abuse.html',
            controller: 'ReportAbuseFormInstanceCtrl',
            resolve: {
              currentLocation: function() {
                return currentLocation;
              }
            }
          });
        };
      }
    };
  });

  module.directive('reportAbuse', function($modal) {
    return {
      restrict: 'A',
      scope: true,
      link: function(scope, element, attributes) {
        return scope.showReportAbusePopup = function(currentLocation) {
          var modalInstance;
          return modalInstance = $modal.open({
            templateUrl: '/views/base/abuse.html',
            controller: 'ReportAbuseFormInstanceCtrl',
            resolve: {
              currentLocation: function() {
                return currentLocation;
              }
            }
          });
        };
      }
    };
  });

}).call(this);
