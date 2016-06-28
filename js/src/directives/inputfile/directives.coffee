module = angular.module('commons.directives.inputfile', [])

module.directive('inputfile', [ ->
    return {
      restrict: 'E'
      scope: {
        setTitle: '&'
        id: '='
        fileread: '='
        label: '='
      }
      template: '''
        <input id="{{id}}" class="inputfile" type="file" ng-model="fileread" />
        <label for="{{id}}" class="btn btn-primary">{{label}}</label>
      '''
      link: (scope, el, attrs) ->
          el.bind 'change', (changeEvent) ->
              scope.$apply ->
                  scope.fileread = changeEvent.target.files[0]
                  return
              scope.setTitle(scope.fileread.name)
    }

])
