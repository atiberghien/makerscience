(function() {
  var DataSharing, FilterService, module;

  module = angular.module("makerscience.base.services", ['restangular']);

  DataSharing = (function() {
    function DataSharing($rootScope1) {
      this.$rootScope = $rootScope1;
      this.sharedObject = {};
    }

    return DataSharing;

  })();

  module.factory('DataSharing', function($rootScope) {
    return new DataSharing($rootScope);
  });

  FilterService = (function() {
    function FilterService($rootScope1) {
      this.$rootScope = $rootScope1;
      console.log("init FilterService");
      this.filterParams = {};
    }

    return FilterService;

  })();

  module.factory('FilterService', function($rootScope) {
    return new FilterService($rootScope);
  });

  module.factory('StaticContent', function(Restangular) {
    return Restangular.service('makerscience/static');
  });

  module.factory('Notification', function(Restangular) {
    return Restangular.service('notification');
  });

}).call(this);
