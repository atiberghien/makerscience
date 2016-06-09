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

module.factory("ProjectCreateService", (ProjectSheetTemplate, ProjectSheet) ->
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

module.factory("ProjectService", (ProjectSheetTemplate, ProjectSheet) ->
    return {
        fetchCoverURL: (projectsheet) ->
            if projectsheet.cover
                return config.media_uri + projectsheet.cover.thumbnail_url+'?dim=710x390&border=true'
            return "/img/default_project.jpg"

        updateProjectSheet: (resources, projectsheet) ->
            putData = {}
            putData[fieldName] = resources.data
            switch resources.resourceName
                when 'Project' then Project.one(resources.resourceId).patch(putData).then((projectResult) ->
                    projectsheet.parent.website = projectResult.website
                    return false
                )
                when 'ProjectSheetQuestionAnswer' then ProjectSheetQuestionAnswer.one(resources.resourceId).patch(putData)
                when 'ProjectSheet' then ProjectSheet.one(resources.resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resources.resourceId).patch(putData)

        openGallery: (projectsheet) ->
            modalInstance = $modal.open(
                templateUrl: '/views/block/gallery.html'
                controller: 'GalleryEditionInstanceCtrl'
                size: 'lg'
                backdrop : 'static'
                keyboard : false
                resolve:
                    projectsheet: ->
                        return projectsheet
            )
            modalInstance.result.then((result)->
                $scope.$emit('cover-updated')
            )
    }
)
