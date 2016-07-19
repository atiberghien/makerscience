module = angular.module("commons.form.services", [])



module.factory("FormService", (ProjectSheetTemplate, ProjectSheet) ->

    FormService = {}

    guid = () ->
      s4 = () ->
        return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1)
      return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4()


    FormService.init = (templateSlug) ->
        projectsheet = {
            medias : {}
        }
        # $scope.QAItems = []
        QAItems = []

        ProjectSheetTemplate.one().get({'slug' : templateSlug}).then((templateResult) ->
            template = templateResult.objects[0]
            angular.forEach(template.questions, (question)->
                QAItems.push(
                    questionLabel : question.text
                    question : question.resource_uri
                    answer : ""
                )
            )
            projectsheet.template = template.resource_uri

            return {
              QAItems: QAItems
              projectsheet: projectsheet
            }
        )

    FormService.save = (projectsheet)->
        if !projectsheet.project
            projectsheet.project.begin_date = new Date()

        ProjectSheet.post(projectsheet).then((response) ->
            return response
        ).catch((error) ->
            console.error error
          )

    return FormService
)
