(function() {
  var module;

  module = angular.module('commons.tags.directives', []);

  module.directive('tagAutoComplete', function(BucketFile, ProjectSheet) {
    return {
      scope: {
        model: '='
      },
      restrict: 'E',
      templateUrl: '<tags-input ng-model="model" placeholder="Mot-clé">\n    <auto-complete source="loadTags($query)" template="{{data.text}} ({{data.weight}})"></auto-complete>\n</tags-input>',
      link: function(scope) {
        return console.log(scope);
      }
    };
  });

}).call(this);
