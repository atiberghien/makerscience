(function() {
  var module;

  module = angular.module("makerscience.forum.services", ['restangular']);

  module.factory('MakerSciencePost', function(Restangular) {
    return Restangular.service('makerscience/post');
  });

  module.factory('MakerSciencePostLight', function(Restangular) {
    return Restangular.service('makerscience/postlight');
  });

}).call(this);
