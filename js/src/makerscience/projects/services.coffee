module = angular.module("makerscience.projects.services", ['restangular'])


# Services
module.factory('Project', (Restangular) ->
    return Restangular.service('project/project')
)
module.factory('ProjectNews', (Restangular) ->
    return Restangular.service('project/news')
)

module.factory('ProjectSheet', (Restangular) ->
    return Restangular.service('project/sheet/projectsheet')
)

module.factory('ProjectSheetTemplate', (Restangular) ->
    return Restangular.service('project/sheet/template')
)

module.factory('ProjectSheetQuestionAnswer', (Restangular) ->
    return Restangular.service('project/sheet/question_answer')
)

module.factory('ProjectProgress', (Restangular) ->
    return Restangular.service('projectprogress')
)

module.factory('BucketFile', (Restangular) ->
    return Restangular.service('bucket/file')
)

module.factory('Bucket', (Restangular) ->
    return Restangular.service('bucket/bucket')
)

module.factory("ProjectService", (ProjectSheetTemplate, ProjectSheet) ->
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

        save: (projectsheet)->
            if projectsheet.project.begin_date is undefined
                projectsheet.project.begin_date = new Date()
            console.log projectsheet
            ProjectSheet.post(projectsheet).then((projectsheetResult) ->
                console.log projectsheetResult
                angular.forEach($scope.QAItems, (q_a) ->
                    q_a.projectsheet = projectsheetResult.resource_uri
                    ProjectSheetQuestionAnswer.post(q_a)
                )
                return projectsheetResult
            )
    }
)
