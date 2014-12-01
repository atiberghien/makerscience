module = angular.module("commons.catalog.controllers", ['commons.catalog.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
    $scope.projects = Project.getList().$object
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, $filter, ProjectSheet, Project,
                                       PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->

    $scope.init = ->
        return ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((projectsheetResult) ->
            projectsheet = projectsheetResult.objects[0]
            projectsheet.q_a = []

            templateID = getObjectIdFromURI(projectsheet.template)
            ProjectSheetTemplate.one(templateID).get().then((templateResult) ->
                angular.forEach(templateResult.questions, (question, index) ->
                    itemID = getObjectIdFromURI(projectsheet.items[index])
                    ProjectSheetItem.one(itemID).get().then((itemResult) ->
                        item =
                            'question' : question
                            'answer' : itemResult.answer
                            'id' : itemResult.id
                        projectsheet.q_a.push(item)
                    )
                )
                return projectsheet
            )
        )
    $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheetItem' then ProjectSheetItem.one(resourceId).patch(putData)
)

module.controller("ProjectSheetCreateCtrl", ($scope, ProjectSheet, Project, PostalAddress,
                                             ProjectSheetTemplate, ProjectSheetItem) ->

    $scope.init = (templateSlug) ->
        $scope.projectsheet = {}
        ProjectSheetTemplate.one().get({'slug' : templateSlug}).then((templateResult) ->
            $scope.template = templateResult.objects[0]
        )

    $scope.saveProject = (projectsheet) ->
        $scope.projectsheet = angular.copy(projectsheet);
        if $scope.projectsheet.project.begin_date is undefined
            $scope.projectsheet.project.begin_date = new Date()

        $scope.projectsheet.project.slug = slug($scope.projectsheet.project.title)

        $scope.projectsheet.template = $scope.template.resource_uri

        ProjectSheet.post($scope.projectsheet).then((projectsheetResult) ->
            if $scope.projectsheet.answers
                angular.forEach(projectsheetResult.items, (itemURI, index) ->
                    itemID = getObjectIdFromURI(itemURI)
                    ProjectSheetItem.one(itemID).patch({'answer': $scope.projectsheet.answers[index]})
                )
            return projectsheetResult
        )

)

module.controller("PopularityCtrl", ($scope, $state) ->
    $scope.votePopularity = false
    $scope.previousUserRatings = {}
    $scope.userRatings = {}

    $scope.popularityItems =
        'Original' :
            'maxPopularityScore' : 100
            'objectPopularityScore' : 70
        'Fun' :
            'maxPopularityScore' : 100
            'objectPopularityScore' : 50
        'Prometteur' :
            'maxPopularityScore' : 100
            'objectPopularityScore' : 15

    $scope.saveUserRating = () ->
        angular.forEach($scope.userRatings, (value, key) ->
            if $scope.previousUserRatings[key]
                $scope.popularityItems[key].objectPopularityScore -=  $scope.previousUserRatings[key]
            $scope.previousUserRatings[key] = value
            $scope.popularityItems[key].objectPopularityScore += value
        )
        $scope.votePopularity = false
)

module.controller("ProjectProgressCtrl", ($scope, ProjectProgress) ->
    $scope.progressRange = []
    $scope.selectedClasses = {}

    $scope.updateProgressChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice.id] = "selected"

    $scope.init = (projectProgressRangeSlug) ->
        ProjectProgress.getList({'range__slug' : projectProgressRangeSlug}).then((progressRangeResult) ->
            $scope.progressRange = progressRangeResult
            $scope.updateProgressChoice($scope.progressRange[0])
        )
)
