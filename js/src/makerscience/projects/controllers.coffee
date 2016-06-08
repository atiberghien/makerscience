module = angular.module("makerscience.projects.controllers", ['makerscience.projects.services', 'commons.scout.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
    $scope.projects = Project.getList().$object
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, $filter, ProjectSheet
                                        Project, ProjectSheetQuestionAnswer, Bucket, PostalAddress,
                                        @$http, FileUploader, $modal) ->

    $scope.fetchCoverURL = (projectsheet) ->
        projectsheet.coverURL = "/img/default_project.jpg"
        if $scope.projectsheet.base_projectsheet.cover
            projectsheet.coverURL = $scope.config.media_uri + $scope.projectsheet.base_projectsheet.cover.thumbnail_url+'?dim=710x390&border=true'


    $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData).then((projectResult) ->
                $scope.projectsheet.parent.website = projectResult.website
                return false
            )
            when 'ProjectSheetQuestionAnswer' then ProjectSheetQuestionAnswer.one(resourceId).patch(putData)
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)
            when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

    $scope.openGallery = (projectsheet) ->
        modalInstance = $modal.open(
            templateUrl: '/views/catalog/block/gallery.html'
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
)
