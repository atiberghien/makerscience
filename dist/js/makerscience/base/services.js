(function() {
  var DataSharing, FilterService, module;

  module = angular.module("makerscience.base.services", ['restangular']);

  DataSharing = (function() {
    function DataSharing($rootScope) {
      this.$rootScope = $rootScope;
      this.sharedObject = {};
    }

    return DataSharing;

  })();

  module.factory('DataSharing', function($rootScope) {
    return new DataSharing($rootScope);
  });

  FilterService = (function() {
    function FilterService($rootScope) {
      this.$rootScope = $rootScope;
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

  module.factory('Project', function(Restangular) {
    return Restangular.service('project/project');
  });

  module.factory('ProjectNews', function(Restangular) {
    return Restangular.service('project/news');
  });

  module.factory('ProjectSheet', function(Restangular) {
    return Restangular.service('project/sheet/projectsheet');
  });

  module.factory('ProjectSheetTemplate', function(Restangular) {
    return Restangular.service('project/sheet/template');
  });

  module.factory('ProjectSheetQuestionAnswer', function(Restangular) {
    return Restangular.service('project/sheet/question_answer');
  });

  module.factory('ProjectProgress', function(Restangular) {
    return Restangular.service('projectprogress');
  });

  module.factory('BucketFile', function(Restangular) {
    return Restangular.service('bucket/file');
  });

  module.factory('Bucket', function(Restangular) {
    return Restangular.service('bucket/bucket');
  });

  module.factory('BucketRestangular', function(Restangular, Config) {
    return Restangular.withConfig(function(RestangularConfigurer) {
      RestangularConfigurer.setRequestSuffix('/');
      return RestangularConfigurer.setBaseUrl(Config.bucket_uri);
    });
  });

}).call(this);
