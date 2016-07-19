(function() {
  var module;

  module = angular.module("commons.scout.services", ['restangular']);

  module.factory('PostalAddress', function(Restangular) {
    return Restangular.service('scout/postaladdress');
  });

}).call(this);
