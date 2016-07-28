module = angular.module('commons.directives.reportabuse', [])

module.directive('reportAbuseButton', ($modal) ->
    return {
      restrict: 'E'
      scope: true
      template: '''
        <a class="report-abuse" ng-click="showReportAbusePopup(location.protocol() + '://' + location.host() + '' + location.path())">
            <i class="fa fa-exclamation-circle"></i> Signaler un contenu abusif
        </a>
      '''
      link: (scope, element, attributes) ->
          scope.showReportAbusePopup = (currentLocation) ->
            modalInstance = $modal.open(
                templateUrl: '/views/base/abuse.html'
                controller: 'ReportAbuseFormInstanceCtrl'
                resolve:
                    currentLocation : () ->
                        return currentLocation
            )

    }

)

module.directive('reportAbuse', ($modal) ->
    return {
      restrict: 'A'
      scope: true
      link: (scope, element, attributes) ->
          scope.showReportAbusePopup = (currentLocation) ->
            modalInstance = $modal.open(
                templateUrl: '/views/base/abuse.html'
                controller: 'ReportAbuseFormInstanceCtrl'
                resolve:
                    currentLocation : () ->
                        return currentLocation
            )

    }

)
