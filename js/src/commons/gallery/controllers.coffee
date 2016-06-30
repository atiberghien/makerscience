module = angular.module('commons.gallery.controllers', [])

module.controller('GalleryCreationProjectCtrl', ($scope, GalleryService, ProjectSheet, BucketFile) ->
    $scope.config = config
    $scope.newMedia = GalleryService.initMediaProject('image')

    $scope.coverId = if $scope.projectsheet.cover then $scope.projectsheet.cover.id else null
    GalleryService.setCoverId($scope.coverId)

    $scope.toggleCoverCandidate = (media) ->
        $scope.coverId = GalleryService.setCoverId(media.id)

        if $scope.projectsheet.id
            $scope.projectsheet.cover = media
            ProjectSheet.one($scope.projectsheet.id).patch({cover: media.resource_uri})

    $scope.setTitle = (title) ->
        $scope.$apply ->
            $scope.newMedia.title = title
            return

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid
            return false

        if newMedia.type == 'video'
            newMedia.videoId = newMedia.url.split('/').pop()
            newMedia.videoProvider = GalleryService.getVideoProvider(newMedia.url)

        $scope.medias.push(newMedia)
        $scope.newMedia = GalleryService.initMediaProject(newMedia.type)
        $scope.submitted = false

    $scope.remove = (media) ->

        mediaIndex = $scope.medias.indexOf(media)
        if $scope.coverId == media.id
            GalleryService.setCoverId(null)

        if mediaIndex != -1
            $scope.medias.splice(mediaIndex, 1)

        else
            if $scope.projectsheet.bucket
                BucketFile.one(media.id).remove().then(->
                    fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media)
                    $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
                )
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

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || (!$scope.newMedia.url && !$scope.newMedia.file)
            console.log 'invalid form'
            return false

        uniqueId = _.uniqueId()
        $scope.projectsheet.medias = []


        $scope.submitted = false

    $scope.cancel = ->
        $scope.uploader.clearQueue()

    $scope.delVideo = (videoURL) ->
        delete $scope.videos[videoURL]
)

module.controller('GalleryEditionInstanceCtrl', ($scope, $modalInstance, projectsheet, medias, ProjectService, ProjectSheet, BucketFile, GalleryService) ->
    $scope.config = config
    $scope.projectsheet = projectsheet
    $scope.hideControls = false
    $scope.medias = medias

    $scope.ok = ->
        if $scope.medias.length
            promises = []
            angular.forEach($scope.medias, (media, index) ->

                promise = ProjectService.uploadMedia(media, $scope.projectsheet.bucket.id, $scope.projectsheet.id)
                promises.push(promise)

                promise.then((res) ->
                    if $scope.coverId != null
                        ProjectSheet.one($scope.projectsheet.id).patch({cover: res.resource_uri})
                  )
            )

            Promise.all(promises).then(() ->
                $modalInstance.dismiss()
                $scope.medias = []
            ).catch((err) ->
                console.error err
            )
        else
            $modalInstance.dismiss()

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')
)
