(function() {
  var module;

  module = angular.module("commons.ucomment.services", ['restangular']);

  module.factory('Comment', function(Restangular) {
    return Restangular.service('comment');
  });

}).call(this);
