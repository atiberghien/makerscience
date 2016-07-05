module = angular.module('commons.tags.directives', [])

module.directive('tagAutoComplete', (Tag) ->
    return {
      scope: {
        model: '='
        placeholder: '@'
      }
      restrict: 'E'
      template: '''
        <tags-input max-length="50" ng-model="model" placeholder="{{placeholder}}">Salut
            <auto-complete source="loadTags($query)" template="{{data.text}} ({{data.weight}})"></auto-complete>
        </tags-input>
      ''',
      controller: 'TagAutoCompleteCtrl'

    }
)
