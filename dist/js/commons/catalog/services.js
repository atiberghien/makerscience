(function() {
  var module;

  module = angular.module("commons.catalog.services", ['restangular']);

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

}).call(this);
