module = angular.module("commons.catalog.controllers", ['commons.catalog.services'])

module.controller("ProjectListCtrl", ($scope, Project) ->
    $scope.projects = Project.getList().$object
)

module.controller("ProjectSheetCtrl", ($scope, $stateParams, $filter, ProjectSheet
                                        Project, ProjectSheetQuestionAnswer, Bucket, Place
                                        @$http, FileUploader, $modal) ->

    $scope.fetchCoverURL = (projectsheet) ->
        projectsheet.coverURL = "/img/default_project.jpg"
        if $scope.projectsheet.base_projectsheet.cover
            projectsheet.coverURL = $scope.config.media_uri + $scope.projectsheet.base_projectsheet.cover.thumbnail_url+'?dim=710x390&border=true'


    $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheetQuestionAnswer' then ProjectSheetQuestionAnswer.one(resourceId).patch(putData)
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)
            when 'Place' then Place.one(resourceId).patch(putData)

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

module.controller("ProjectSheetCreateCtrl", ($rootScope, $scope, ProjectSheet, Project,
                                             ProjectSheetTemplate, ProjectSheetQuestionAnswer,
                                             @$http, FileUploader, $modal, ObjectProfileLink) ->

    $scope.uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )
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

        $scope.projectsheet.project.slug = slug($scope.projectsheet.project.title)

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

module.controller('GalleryCreationInstanceCtrl', ($scope, $modalInstance, uploader) ->

    $scope.videos = {}
    $scope.coverCandidateQueueIndex = null

    $scope.uploader = uploader

    $scope.ok = ->
        $modalInstance.close({
            coverCandidateQueueIndex : $scope.coverCandidateQueueIndex,
            videos : $scope.videos
        })

    $scope.cancel = ->
        $scope.uploader.clearQueue()
        $modalInstance.dismiss('cancel')

    $scope.isCoverCandidate = (fileItem) ->
        fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem)
        return $scope.coverCandidateQueueIndex != null && $scope.coverCandidateQueueIndex == fileQueueIndex

    $scope.toggleCoverCandidate = (fileItem) ->
        if $scope.isCoverCandidate(fileItem)
            $scope.coverCandidateQueueIndex = null
        else
            $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem)

    $scope.addVideo = (newVideoURL) ->
        $scope.videos[newVideoURL] = null

    $scope.delVideo = (videoURL) ->
        delete $scope.videos[videoURL]
)

module.controller('GalleryEditionInstanceCtrl', ($scope, $modalInstance, @$http, projectsheet, FileUploader, ProjectSheet, BucketFile) ->

    $scope.projectsheet = projectsheet
    $scope.coverCandidateQueueIndex = null

    $scope.hideControls = false

    $scope.uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )

    if !$scope.projectsheet.videos
        $scope.projectsheet.videos = {}
    $scope.videos = $scope.projectsheet.videos

    $scope.uploader.onBeforeUploadItem = (item) ->
        item.formData.push(
            bucket : $scope.projectsheet.bucket.id
        )
        item.headers =
           Authorization : $scope.uploader.headers["Authorization"]

    # must use tmp var in order to not modify queue during cover candidate saving ... sync issue
    $scope.tmpBucketFiles = []
    $scope.tmpNewCover = null
    $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
        if $scope.isCoverCandidate(fileItem)
            $scope.tmpNewCover = response
        $scope.tmpBucketFiles.push(response)

    $scope.uploader.onCompleteAll = () ->
        if $scope.tmpNewCover
            $scope.toggleCover($scope.tmpNewCover).then(->
                angular.forEach($scope.tmpBucketFiles, (file) ->
                    $scope.projectsheet.bucket.files.push(file)
                )
            )
        else
            angular.forEach($scope.tmpBucketFiles, (file) ->
                $scope.projectsheet.bucket.files.push(file)
            )
        $modalInstance.close()

    $scope.ok = ->
        if $scope.uploader.queue.length > 0
            $scope.uploader.uploadAll()
        else
            $scope.uploader.onCompleteAll()

    $scope.cancel = ->
        $scope.uploader.clearQueue()
        $modalInstance.dismiss('cancel')

    $scope.removePicture = (file) ->
        if $scope.isCover(file)
            $scope.toggleCover(file) #reset cover

        BucketFile.one(file.id).remove().then(->
            fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(file)
            $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
        )

    $scope.isCoverCandidate = (fileItem) ->
        fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem)
        return $scope.coverCandidateQueueIndex != null && $scope.coverCandidateQueueIndex == fileQueueIndex

    $scope.isCover = (file) ->
        return $scope.projectsheet.cover != null && $scope.projectsheet.cover.id == file.id

    $scope.toggleCoverCandidate = (fileItem) ->
        if $scope.isCoverCandidate(fileItem)
            $scope.coverCandidateQueueIndex = null
        else
            $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem)

    $scope.toggleCover = (file) ->
        if $scope.isCover(file)
            $scope.projectsheet.cover = null
            return ProjectSheet.one($scope.projectsheet.id).patch({cover:null})
        else
            $scope.projectsheet.cover = file
            return ProjectSheet.one($scope.projectsheet.id).patch({cover:file.resource_uri})

    $scope.addVideo = (newVideoURL) ->
        $scope.projectsheet.videos[newVideoURL] = null
        $scope.videos[newVideoURL] = null # just for display concerns
        ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.projectsheet.videos})

    $scope.delVideo = (videoURL) ->
        delete $scope.projectsheet.videos[videoURL]
        delete $scope.videos[videoURL] # just for display concerns
        ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.projectsheet.videos})
)
