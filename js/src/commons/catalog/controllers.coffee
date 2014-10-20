module = angular.module("commons.catalog.controllers", ['commons.catalog.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
	$scope.projects = Project.getList().$object;
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, ProjectSheet, Project, PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->
    ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((projectsheetResult) ->
        console.log(projectsheetResult)
        $scope.projectsheet = projectsheetResult.objects[0]
        projectID = getObjectIdFromURI($scope.projectsheet.project)
        Project.one(projectID).get().then((projectResult) ->
            $scope.projectsheet.project = projectResult
            if $scope.projectsheet.project.location
                postalAddressId = getObjectIdFromURI($scope.projectsheet.project.location)
                $scope.projectsheet.project.location = PostalAddress.one(postalAddressId).get().$object
                
        )
        
        $scope.projectsheet.q_a = []
        templateID = getObjectIdFromURI($scope.projectsheet.template)
        
        fillAnswer = (question, i) ->
            itemID = getObjectIdFromURI($scope.projectsheet.items[i])
            ProjectSheetItem.one(itemID).get().then((itemResult) ->
                item = 
                    'question' : question
                    'answer' : itemResult.answer
                    'id' : itemResult.id
                $scope.projectsheet.q_a.push(item)
            )
        
        ProjectSheetTemplate.one(templateID).get().then((templateResult) ->
            fillAnswer(question, i) for question, i in templateResult.questions

        )
    )
    
    $scope.update = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheetItem' then ProjectSheetItem.one(resourceId).patch(putData)
    
)

module.controller("ProjectSheetCreateCtrl", ($scope, $state, ProjectSheet, Project, PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->
    $scope.projectsheet = {}
    ProjectSheetTemplate.one().get({'slug' : 'makerscience'}).then((templateResult) ->
        $scope.template = templateResult.objects[0]
    )
    
    $scope.save = (projectsheet) ->
        console.log("ProjectSheetCreateCtrl.save()")
        $scope.projectsheet = angular.copy(projectsheet);
        if $scope.projectsheet.project.begin_date is undefined
            $scope.projectsheet.project.begin_date = new Date()
        $scope.projectsheet.project.slug = slug($scope.projectsheet.project.title)
        Project.post($scope.projectsheet.project).then((projectResult) ->
            $scope.projectsheet.project = projectResult.resource_uri
            $scope.projectsheet.template = $scope.template.resource_uri
            
            postAnswer = (itemURI, answer) ->
                itemID = getObjectIdFromURI(itemURI)
                ProjectSheetItem.one(itemID).patch({'answer': answer})
                    
            ProjectSheet.post($scope.projectsheet).then((projectsheetResult) ->
                postAnswer(itemURI, $scope.projectsheet.answers[i]) for itemURI, i in projectsheetResult.items
            )
            $state.go('projectsheet', {'slug' : projectResult.slug})            
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