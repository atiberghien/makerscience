module = angular.module('commons.tags.directives', [])

module.directive('tagAutoComplete', (Tag) ->
    return {
      scope: {
        model: '='
        placeholder: '@'
      }
      restrict: 'E'
      template: '''
        <tags-input ng-model="model" placeholder="{{placeholder}}">
            <auto-complete source="loadTags($query)" template="{{data.text}} ({{data.weight}})"></auto-complete>
        </tags-input>
      ''',
      controller: 'TagAutoCompleteCtrl'

    }
)
