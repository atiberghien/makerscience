module = angular.module("makerscience.projects.controllers")

module.controller("ProjectSheetCreateCtrl", ($rootScope, $scope, ProjectSheet, Project,
                                             ProjectSheetTemplate, ProjectSheetQuestionAnswer,
                                             $modal, ObjectProfileLink) ->

    $scope.coverIndex = null #To define which photo will be the cover

    $scope.initProjectSheetCreateCtrl = (templateSlug) ->
        $scope.projectsheet =
            videos : {}
        $scope.QAItems = []

        ProjectSheetTemplate.one().get({'slug' : templateSlug}).then((templateResult) ->
            template = templateResult.objects[0]
            angular.forEach(template.questions, (question)->
                $scope.QAItems.push(
                    questionLabel : question.text
                    question : question.resource_uri
                    answer : ""
                )
            )
            $scope.projectsheet.template = template.resource_uri
        )

    $scope.saveProject = ()->
        if $scope.projectsheet.project.begin_date is undefined
            $scope.projectsheet.project.begin_date = new Date()

        ProjectSheet.post($scope.projectsheet).then((projectsheetResult) ->
            angular.forEach($scope.QAItems, (q_a) ->
                q_a.projectsheet = projectsheetResult.resource_uri
                ProjectSheetQuestionAnswer.post(q_a)
            )
            return projectsheetResult
        )

    $scope.openGallery = ->
        modalInstance = $modal.open(
            templateUrl: '/views/catalog/block/gallery.html'
            controller: 'GalleryCreationInstanceCtrl'
            size: 'lg'
            resolve:
                uploader: ->
                    return $scope.uploader
        )
        modalInstance.result.then((result)->
            $scope.coverIndex = result.coverCandidateQueueIndex
            $scope.projectsheet.videos = result.videos
        , () ->
            return
        )
)
