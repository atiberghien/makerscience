module = angular.module("commons.gallery.controllers", [])

module.controller('GalleryCreationInstanceCtrl', ($scope, FileUploader, @$http, ProjectSheet, ProjectService) ->
    $scope.newMedia = {
        title: 'title'
    }

    $scope.setTitle = (title) ->
        $scope.$apply ->
          $scope.newMedia.title = title
          return

    $scope.tabSelect = (type) ->
        $scope.newMedia = {
          title: ''
          type: type
        }

    $scope.videos = {}
    $scope.coverCandidateQueueIndex = null

    $scope.uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )
    # $scope.uploader = $rootScope.uploader

    # $scope.ok = ->
    #     $modalInstance.close({
    #         coverCandidateQueueIndex : $scope.coverCandidateQueueIndex,
    #         videos : $scope.videos
    #     })

    $scope.cancel = ->
        $scope.uploader.clearQueue()
        # $modalInstance.dismiss('cancel')

    $scope.isCoverCandidate = (fileItem) ->
        fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem)
        return $scope.coverCandidateQueueIndex != null && $scope.coverCandidateQueueIndex == fileQueueIndex

    $scope.toggleCoverCandidate = (fileItem) ->
        if $scope.isCoverCandidate(fileItem)
            $scope.coverCandidateQueueIndex = null
        else
            $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem)

    $scope.addMedia = (media) ->
        ProjectSheet.one(projectsheetResult.id).patch({videos:$scope.projectsheet.videos})

        $scope.uploader.onBeforeUploadItem = (item) ->
            item.formData.push(
                bucket : projectsheetResult.bucket.id
            )
            item.headers =
               Authorization : $scope.uploader.headers["Authorization"]

        $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
            if $scope.uploader.getIndexOfItem(fileItem) == $scope.coverIndex
                ProjectSheet.one(projectsheetResult.id).patch({cover:response.resource_uri})

        $scope.uploader.onCompleteAll = () ->
            console.log('complete all')

        $scope.uploader.uploadAll()


    $scope.addVideo = (newVideoURL) ->
        $scope.videos[newVideoURL] = null

    $scope.delVideo = (videoURL) ->
        delete $scope.videos[videoURL]
)
#
# module.controller('GalleryEditionInstanceCtrl', ($scope, $modalInstance, @$http, projectsheet, FileUploader, ProjectSheet, BucketFile) ->
#
#     $scope.projectsheet = projectsheet
#     $scope.coverCandidateQueueIndex = null
#
#     $scope.hideControls = false
#
#     $scope.uploader = new FileUploader(
#         url: config.bucket_uri
#         headers :
#             Authorization : @$http.defaults.headers.common.Authorization
#     )
#
#     if !$scope.projectsheet.videos
#         $scope.projectsheet.videos = {}
#     $scope.videos = $scope.projectsheet.videos
#
#     $scope.uploader.onBeforeUploadItem = (item) ->
#         item.formData.push(
#             bucket : $scope.projectsheet.bucket.id
#         )
#         item.headers =
#            Authorization : $scope.uploader.headers["Authorization"]
#
#     # must use tmp var in order to not modify queue during cover candidate saving ... sync issue
#     $scope.tmpBucketFiles = []
#     $scope.tmpNewCover = null
#     $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
#         if $scope.isCoverCandidate(fileItem)
#             $scope.tmpNewCover = response
#         $scope.tmpBucketFiles.push(response)
#
#     $scope.uploader.onCompleteAll = () ->
#         if $scope.tmpNewCover
#             $scope.toggleCover($scope.tmpNewCover).then(->
#                 angular.forEach($scope.tmpBucketFiles, (file) ->
#                     $scope.projectsheet.bucket.files.push(file)
#                 )
#             )
#         else
#             angular.forEach($scope.tmpBucketFiles, (file) ->
#                 $scope.projectsheet.bucket.files.push(file)
#             )
#         $modalInstance.close()
#
#     $scope.ok = ->
#         if $scope.uploader.queue.length > 0
#             $scope.uploader.uploadAll()
#         else
#             $scope.uploader.onCompleteAll()
#
#     $scope.cancel = ->
#         $scope.uploader.clearQueue()
#         $modalInstance.dismiss('cancel')
#
#     $scope.removePicture = (file) ->
#         if $scope.isCover(file)
#             $scope.toggleCover(file) #reset cover
#
#         BucketFile.one(file.id).remove().then(->
#             fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(file)
#             $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
#         )
#
#     $scope.isCoverCandidate = (fileItem) ->
#         fileQueueIndex = $scope.uploader.getIndexOfItem(fileItem)
#         return $scope.coverCandidateQueueIndex != null && $scope.coverCandidateQueueIndex == fileQueueIndex
#
#     $scope.isCover = (file) ->
#         return $scope.projectsheet.cover != null && $scope.projectsheet.cover.id == file.id
#
#     $scope.toggleCoverCandidate = (fileItem) ->
#         if $scope.isCoverCandidate(fileItem)
#             $scope.coverCandidateQueueIndex = null
#         else
#             $scope.coverCandidateQueueIndex = $scope.uploader.getIndexOfItem(fileItem)
#
#     $scope.toggleCover = (file) ->
#         if $scope.isCover(file)
#             $scope.projectsheet.cover = null
#             return ProjectSheet.one($scope.projectsheet.id).patch({cover:null})
#         else
#             $scope.projectsheet.cover = file
#             return ProjectSheet.one($scope.projectsheet.id).patch({cover:file.resource_uri})
#
#     $scope.addVideo = (newVideoURL) ->
#         $scope.projectsheet.videos[newVideoURL] = null
#         $scope.videos[newVideoURL] = null # just for display concerns
#         ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.projectsheet.videos})
#
#     $scope.delVideo = (videoURL) ->
#         delete $scope.projectsheet.videos[videoURL]
#         delete $scope.videos[videoURL] # just for display concerns
#         ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.projectsheet.videos})
# )
