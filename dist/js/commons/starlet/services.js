(function() {
  var module;

  module = angular.module("commons.starlet.services", ['restangular']);

  module.factory('Vote', function(Restangular) {
    return Restangular.service('vote');
  });

}).call(this);
