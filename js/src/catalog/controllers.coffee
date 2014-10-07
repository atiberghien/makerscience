module = angular.module("projectsheet.controllers", ['projectsheet.services', ])

module.controller("ProjectListCtrl", ($scope, Project) ->
	$scope.projects = Project.getList().$object;
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, ProjectSheet, Project, PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->
    ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((projectsheetResult) ->
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
                $scope.projectsheet.q_a.push(item)
            )
        
        ProjectSheetTemplate.one(templateID).get().then((templateResult) ->
            fillAnswer(question, i) for question, i in templateResult.questions

        )
    )
)

module.controller("ProjectSheetCreateCtrl", ($scope, $state, ProjectSheet, Project, PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->
    $scope.projectsheet = {}
    
    ProjectSheetTemplate.one().get({'slug' : 'makerscience'}).then((templateResult) ->
        $scope.template = templateResult.objects[0]
    )
    
    $scope.save = (projectsheet) ->
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
