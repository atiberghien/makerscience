module = angular.module("commons.form.services", [])

module.factory("FormService", (ProjectSheetTemplate, ProjectSheet) ->
    return {
        init: (templateSlug) ->
            projectsheet =
                videos : {}
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

        save: (projectsheet, QAItems)->
            if projectsheet.project.begin_date is undefined
                projectsheet.project.begin_date = new Date()

            ProjectSheet.post(projectsheet).then((projectsheetResult) ->
                return projectsheetResult
            )
    }
)
