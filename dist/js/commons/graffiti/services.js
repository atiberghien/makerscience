(function() {
  var module;

  module = angular.module("commons.graffiti.services", ['restangular']);

  module.factory('Tag', function(Restangular) {
    return Restangular.service('tag');
  });

  module.factory('TaggedItem', function(Restangular) {
    return Restangular.service('taggeditem');
  });

}).call(this);
