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
      link: (scope) ->
        scope.loadTags = (query) ->
            return Tag.getList().then((tagResults) ->
                availableTags = []
                angular.forEach(tagResults, (tag) ->
                    if tag.name.indexOf(query) > -1
                        tmpTag =
                            'text' : tag.name
                            'weight' : tag.weight
                        availableTags.push(tmpTag)
                )
                return availableTags
            )

    }
)
