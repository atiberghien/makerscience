(function() {
  var module;

  module = angular.module("commons.form.services", []);

  module.factory("FormService", function(ProjectSheetTemplate, ProjectSheet) {
    var FormService, guid;
    FormService = {};
    guid = function() {
      var s4;
      s4 = function() {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
      };
      return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4();
    };
    FormService.init = function(templateSlug) {
      var QAItems, projectsheet;
      projectsheet = {
        medias: {}
      };
      QAItems = [];
      return ProjectSheetTemplate.one().get({
        'slug': templateSlug
      }).then(function(templateResult) {
        var template;
        template = templateResult.objects[0];
        angular.forEach(template.questions, function(question) {
          return QAItems.push({
            questionLabel: question.text,
            question: question.resource_uri,
            answer: ""
          });
        });
        projectsheet.template = template.resource_uri;
        return {
          QAItems: QAItems,
          projectsheet: projectsheet
        };
      });
    };
    FormService.save = function(projectsheet) {
      if (!projectsheet.project) {
        projectsheet.project.begin_date = new Date();
      }
      return ProjectSheet.post(projectsheet).then(function(response) {
        return response;
      })["catch"](function(error) {
        return console.error(error);
      });
    };
    return FormService;
  });

}).call(this);
