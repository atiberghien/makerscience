module = angular.module("imagination.catalog.controllers", ['commons.graffiti.controllers', "commons.accounts.controllers", "commons.accounts.services", 
                                                        'commons.base.services','commons.catalog.services'])

# module.controller("MakerScienceProjectListCtrl", ($scope, $controller, MakerScienceProject) ->
#     angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))
    
#     $scope.refreshList = ()->
#         $scope.projects = MakerScienceProject.one().customGETLIST('search', $scope.params).$object
    
# )


module.controller("ImaginationProjectSheetCreateCtrl", ($scope, $state, $controller, Project, ProjectSheet, TaggedItem, Profile, ObjectProfileLink) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})

    $scope.tags = []

    $scope.saveImaginationProject = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            return false
        else
            console.log("submitting form")
        
        $scope.saveProject().then((projectsheetResult) ->
            console.log(" Just saved project : Result from savingProject : ", projectsheetResult)
            
            # Here we assign tags to projects 
            angular.forEach($scope.tags, (tag)->
                TaggedItem.one().customPOST({tag : tag.text}, "project/"+projectsheetResult.project.id, {})
            )

            $scope.saveVideos(projectsheetResult.id)
            # if no photos to upload, directly go to new project sheet
            if $scope.uploader.queue.length <= 0
                $state.go("project.detail", {slug : projectsheetResult.project.slug})
            else
                $scope.savePhotos(projectsheetResult.id, projectsheetResult.bucket.id)
                $scope.uploader.onCompleteAll = () ->
                    $state.go("project.detail", {slug : projectsheetResult.project.slug})
            
            # add connected user as team member of project with detail "porteur"
            # FIXME : 
            # a) check currentProfile get populated (see commons.accounts.services)
            # b) implement permissions !
            # ObjectProfileLink.one().customPOST(
            #         profile_id: $scope.currentProfile.id,
            #         level: 0,
            #         detail : "Créateur/Créatrice",
            #         isValidated:true
            #         , 'project/'+getObjectIdFromURI(projectsheetResult.project)).then((objectProfileLinkResult) ->
            #                 console.log("added current user as team member", objectProfileLinkResult.profile)
            #                 MakerScienceProject.one(makerscienceProjectResult.id).customPOST({"user_id":objectProfileLinkResult.profile.user.id}, 'assign').then((result)->
            #                         console.log(" succesfully assigned edit rights ? : ", result)
            #                 )
            #         )
        )

)


module.controller("ImaginationProjectSheetCtrl", ($rootScope, $scope, $stateParams, $controller, Project, ProjectSheet, TaggedItem, ObjectProfileLink, DataSharing) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})
    $controller('TaggedItemCtrl', {$scope: $scope})

    $scope.preparedTags = []
    $scope.currentUserHasEditRights = false
    $scope.editable = false

    ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((ProjectSheetResult) ->
        $scope.projectsheet = ProjectSheetResult.objects[0]
        console.log(" project sheet ", $scope.projectsheet)

        # FIXME : permissions ?
        # if $rootScope.authVars.user
        #     MakerScienceProject.one($scope.projectsheet.id).one('check', $rootScope.authVars.user.id).get().then((result)->
        #         console.log(" Has current user edit rights ?", result.has_perm)
        #         $scope.currentUserHasEditRights = result.has_perm
        #         $scope.editable = result.has_perm

        # )
        
        DataSharing.sharedObject = {project: $scope.projectsheet.project}
        angular.forEach($scope.projectsheet.project.tags, (taggedItem) ->
            $scope.preparedTags.push({text : taggedItem.name, taggedItemId : taggedItem.id})
        )

        # FIXME : would not cost much to get similar projects 
        # $scope.similars = []
        # TaggedItem.one().customGET("makerscienceproject/"+$scope.projectsheet.id+"/similars").then((similarResults) ->
        #     angular.forEach(similarResults, (similar) ->
        #         if similar.type == 'makerscienceproject'
        #             $scope.similars.push(MakerScienceProject.one(similar.id).get().$object)
        #     )

        # FIXME ; deal with newly added user for permissions
        # $scope.$on('newTeamMember', (event, user_id)->
        #         """
        #         Give edit rights to newly added or validated team member (see commons.accounts.controllers)
        #         """
        #         console.log(" giving edit rights to user id = ", user_id)
        #         MakerScienceProject.one($scope.projectsheet.id).customPOST({"user_id":user_id}, 'assign').then((result)->
        #             console.log(" succesfully assigned edit rights ? : ", result)
        #             )
        #     )

    )

    $scope.updateImaginationProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)
)

