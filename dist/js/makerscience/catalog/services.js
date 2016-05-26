(function() {
  var module;

  module = angular.module("makerscience.catalog.services", ['restangular']);

  module.factory('MakerScienceProject', function(Restangular) {
    return Restangular.service('makerscience/project');
  });

  module.factory('MakerScienceResource', function(Restangular) {
    return Restangular.service('makerscience/resource');
  });

  module.factory('MakerScienceProjectLight', function(Restangular) {
    return Restangular.service('makerscience/projectlight');
  });

  module.factory('MakerScienceResourceLight', function(Restangular) {
    return Restangular.service('makerscience/resourcelight');
  });

  module.factory('MakerScienceProjectTaggedItem', function(Restangular) {
    return Restangular.service('makerscience/projecttaggeditem');
  });

  module.factory('MakerScienceResourceTaggedItem', function(Restangular) {
    return Restangular.service('makerscience/resourcetaggeditem');
  });

}).call(this);
