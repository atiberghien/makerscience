module = angular.module('commons.gallery.controllers', [])

module.controller('GalleryCreationProjectCtrl', ($scope, GalleryService) ->
    $scope.currentType = null
    $scope.config = config
    $scope.coverIndex = null

    $scope.setTitle = (title) ->
        $scope.$apply ->
            $scope.newMedia.title = title
            return

    $scope.initMedia = (type) ->
        $scope.newMedia = GalleryService.initMediaProject(type)
        $scope.currentType = type

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || (!$scope.newMedia.url && !$scope.newMedia.file)
            console.log 'invalid form'
            return false

        if newMedia.file
            newMedia.bucket = true
        else
            newMedia.bucket = false

        id = _.size($scope.medias)
        $scope.medias[id] = newMedia
        if $scope.tmpMedias
            $scope.tmpMedias[id] = newMedia
        $scope.initMedia(newMedia.type)
        $scope.submitted = false

    $scope.toggleCoverCandidate = (index) ->
        $scope.coverIndex = GalleryService.setCoverIndex(index)
)

module.controller('GalleryCreationResourceCtrl', ($scope, ProjectSheet) ->
    $scope.currentType = null
    $scope.setTitle = (title) ->
        $scope.$apply ->
          $scope.newMedia.title = title
          return

    $scope.tabSelect = (type) ->
        $scope.newMedia = GalleryService.initMediaResource()
        $scope.currentType = type

    $scope.config = config
    $scope.coverCandidateQueueIndex = null

    $scope.uploader.onAfterAddingFile = (item) ->
      item.file.name = $scope.newMedia.title
      $scope.newMedia = { type: $scope.currentType }

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || (!$scope.newMedia.url && !$scope.newMedia.file)
            console.log 'invalid form'
            return false

        # if newMedia.file
        #     $scope.newMedia = newMedia
        #     newMedia.bucket = true
        #     $scope.uploader.addToQueue(newMedia.file)
        # else
        #     newMedia.bucket = false

        uniqueId = _.uniqueId()
        # $scope.projectsheet.medias[uniqueId] = newMedia
        $scope.projectsheet.medias = []


        $scope.submitted = false

    $scope.cancel = ->
        $scope.uploader.clearQueue()

    $scope.isCoverCandidate = (fileIndex) ->
        return $scope.coverCandidateQueueIndex != null && $scope.coverCandidateQueueIndex == fileIndex

    $scope.toggleCoverCandidate = (fileIndex) ->
        if $scope.isCoverCandidate(fileIndex)
            $scope.coverCandidateQueueIndex = null
        else
            $scope.coverCandidateQueueIndex = fileIndex

    $scope.delVideo = (videoURL) ->
        delete $scope.videos[videoURL]
)

module.controller('GalleryEditionInstanceCtrl', ($scope, $modalInstance, projectsheet, medias, ProjectService, ProjectSheet, BucketFile, GalleryService) ->
    $scope.currentType = null
    $scope.config = config
    $scope.projectsheet = projectsheet
    $scope.hideControls = false
    $scope.newMedia = {}
    $scope.medias = medias

    $scope.ok = ->
        $scope.coverIndex = GalleryService.coverIndex
        if _.size($scope.medias) != 0
            promises = []
            angular.forEach($scope.medias, (media, index) ->
                promise = ProjectService.uploadMedia(media, $scope.projectsheet.bucket.id, $scope.projectsheet.id)
                promises.push(promise)

                promise.then((res) ->
                    if $scope.coverIndex != null
                        ProjectSheet.one($scope.projectsheet.id).patch({cover: res.resource_uri})
                  )
            )

            Promise.all(promises).then(() ->
                $modalInstance.dismiss()
                $scope.medias = {}
            ).catch((err) ->
                console.error err
            )
        else
            $modalInstance.dismiss()

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')

    $scope.remove = (media) ->
        if $scope.isCover(media)
            $scope.toggleCover(media) #reset cover

        BucketFile.one(media.id).remove().then(->
            fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media)
            $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
        )

    $scope.isCover = (media) ->
        return $scope.projectsheet.cover != null && $scope.projectsheet.cover.id == media.id

    $scope.toggleCoverCandidate = (index) ->
        $scope.coverIndex = GalleryService.setCoverIndex(index)

    $scope.toggleCover = (file) ->
        if $scope.isCover(file)
            $scope.projectsheet.cover = null
            return ProjectSheet.one($scope.projectsheet.id).patch({cover:null})
        else
            $scope.projectsheet.cover = file
            return ProjectSheet.one($scope.projectsheet.id).patch({cover:file.resource_uri})

)
