(function() {
  var module;

  module = angular.module('commons.tags.directives', []);

  module.directive('tagAutoComplete', function(Tag) {
    return {
      scope: {
        model: '=',
        placeholder: '@'
      },
      restrict: 'E',
      template: '<tags-input max-length="50" ng-model="model" placeholder="{{placeholder}}">\n    <auto-complete source="loadTags($query)" template="{{data.text}} ({{data.weight}})"></auto-complete>\n</tags-input>',
      controller: 'TagAutoCompleteCtrl'
    };
  });

}).call(this);
