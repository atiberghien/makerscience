module = angular.module("commons.catalog.controllers", ['commons.catalog.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
    $scope.projects = Project.getList().$object
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, $filter, ProjectSheet, Project,
                                       PostalAddress, ProjectSheetTemplate, ProjectSheetItem, BucketFile, Bucket) ->


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
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)

    $scope.loadBucketFiles = (BucketUri) ->
        Bucket.one(getObjectIdFromURI(BucketUri)).get().then((data)->
            $scope.bucket = data.files
        )
)

module.controller("ProjectSheetCreateCtrl", ($scope, ProjectSheet, Project, PostalAddress,
                                             ProjectSheetTemplate, ProjectSheetItem,
                                             @$http, FileUploader, $modal) ->

    $scope.uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )
    $scope.favorite = "-1" #To define which photo will be the cover
    $scope.videos = {}


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

    $scope.savePhotos = (projectsheetID, bucketID) ->
        angular.forEach($scope.uploader.queue, (item) ->
            item.formData.push(
                bucket : bucketID
            )
            item.headers =
               Authorization : $scope.uploader.headers["Authorization"]
        )
        $scope.uploader.uploadAll()

        $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
            if $scope.uploader.getIndexOfItem(fileItem) == $scope.favorite
                ProjectSheet.one(projectsheetID).patch({cover:response.resource_uri})

    $scope.saveVideos = (projectsheetID) ->
        ProjectSheet.one(projectsheetID).patch({videos:$scope.videos})

    $scope.openGallery = ->
        modalInstance = $modal.open(
            templateUrl: 'views/catalog/block/gallery.html'
            controller: 'GalleryInstanceCtrl'
            size: 'lg'
            resolve:
                params: ->
                    return {uploader : $scope.uploader, videos : $scope.videos, favorite : $scope.favorite}
        )
        modalInstance.result.then((result)->
            $scope.favorite = result.favorite
        , () ->
            return
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

module.controller("ProjectProgressCtrl", ($scope, Project, ProjectProgress) ->
    $scope.progressRange = []
    $scope.selectedClasses = {}

    $scope.updateProgressChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice.id] = "selected"

    $scope.init = (projectID, projectProgressRangeSlug) ->

        ProjectProgress.getList({'range__slug' : projectProgressRangeSlug}).then((progressRangeResult) ->
            $scope.progressRange = progressRangeResult
            $scope.updateProgressChoice($scope.progressRange[0])
        )

)

module.controller('GalleryInstanceCtrl', ($scope, $modalInstance, params) ->
    $scope.uploader = params.uploader
    $scope.videos = params.videos
    $scope.favorite = params.favorite

    $scope.ok = ->
        result =
            uploader : $scope.uploader
            videos : $scope.videos
            favorite : $scope.favorite
        $modalInstance.close(result)

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')

    $scope.addVideo = (newVideosURL) ->
        $scope.videos[newVideosURL] = null

    $scope.delVideo = (videosURL) ->
        delete $scope.videos[videosURL]

    $scope.setFavorite = (item) ->
        $scope.favorite = $scope.uploader.getIndexOfItem(item)
)
