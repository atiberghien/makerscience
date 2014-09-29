getObjectIdFromURI = (uri) ->
    splitted_uri = uri.split("/")
    return splitted_uri[splitted_uri.length-1]
        
module = angular.module("projectsheet.controllers", ['projectsheet.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
	$scope.projects = Project.getList().$object;
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, ProjectSheet, Project, PostalAddress, ProjectSheetTemplate, ProjectSheetItem) ->
    ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((projectsheetResult) ->
        $scope.projectsheet = projectsheetResult.objects[0]
    
        projectID = getObjectIdFromURI($scope.projectsheet.project)
        Project.one(projectID).get().then((projectResult) ->
            $scope.projectsheet.project = projectResult
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
