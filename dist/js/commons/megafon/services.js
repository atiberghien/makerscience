(function() {
  var module;

  module = angular.module("commons.megafon.services", ['restangular']);

  module.factory('Post', function(Restangular) {
    return Restangular.service('megafon/post');
  });

}).call(this);
