module = angular.module('commons.gallery.controllers', [])

module.controller('GalleryCreationProjectCtrl', ($scope, GalleryService, ProjectSheet, BucketFile, ProjectService) ->
    $scope.config = config
    $scope.newMedia = GalleryService.initMediaProject('image')

    $scope.$on('images-added', (event, data) ->
      angular.forEach(data, (img, index) ->
          $scope.medias.push({
            type: 'image'
            title: img.alt
            url: img.src
          })
        )
      )

    $scope.coverId = if $scope.projectsheet.cover then $scope.projectsheet.cover.id else null
    GalleryService.setCoverId($scope.coverId)

    $scope.getMediasToShow = () ->
        $scope.mediasToShow = if $scope.projectsheet.bucket then $scope.medias.concat($scope.projectsheet.bucket.files) else $scope.medias

    $scope.getMediasToShow()

    $scope.changeTab = (type) ->
        $scope.newMedia = GalleryService.initMediaProject(type)

    $scope.toggleCoverCandidate = (media) ->
        if media.id == undefined
            media.id = $scope.medias.indexOf(media)

        $scope.coverId = GalleryService.setCoverId(media.id)

        if $scope.projectsheet.id
            $scope.projectsheet.cover = media
            ProjectSheet.one($scope.projectsheet.id).patch({cover: media.resource_uri})

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || $scope.mediaForm.$pristine
            return false

        if newMedia.type == 'video'
            newMedia.video_id = newMedia.url.split('/').pop()
            newMedia.video_provider = GalleryService.getVideoProvider(newMedia.url)

        $scope.medias.push(newMedia)
        $scope.newMedia = GalleryService.initMediaProject(newMedia.type)
        $scope.submitted = false
        $scope.getMediasToShow()
        $scope.mediaForm.$setPristine()

    $scope.remove = (media) ->
        mediaIndex = $scope.medias.indexOf(media)

        if $scope.coverId == media.id
            GalleryService.setCoverId(null)

        if mediaIndex != -1
            $scope.medias.splice(mediaIndex, 1)
            $scope.getMediasToShow()

        else
            if $scope.projectsheet.bucket
                BucketFile.one(media.id).remove().then(->
                    fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media)
                    $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
                    $scope.getMediasToShow()
                )
)

module.controller('GalleryCreationResourceCtrl', (@$rootScope, $scope, $filter, GalleryService, ProjectSheet, BucketFile) ->
    $scope.config = config
    user = @$rootScope.authVars.user
    $scope.user = user.first_name + ' ' + user.last_name
    $scope.newMedia = GalleryService.initMediaResource('document', $scope.user)

    $scope.getFilterMedias = () ->
        medias = if $scope.projectsheet.bucket then $scope.medias.concat($scope.projectsheet.bucket.files) else $scope.medias
        $scope.mediasToShow = $filter('filter')(medias, {type: '!cover'})
        $scope.filteredByAuthor = $filter('filter')($scope.mediasToShow, {is_author: true, type: '!experience'})
        $scope.filteredByNotAuthor = $filter('filter')($scope.mediasToShow, {is_author: false, type: '!experience'})
        $scope.filteredByExperience = $filter('filter')($scope.mediasToShow, {type: 'experience'})

    $scope.getFilterMedias()

    $scope.setUrl = () ->
        if !$scope.newMedia.is_author
            parser = document.createElement('a')
            parser.href = $scope.newMedia.url
            $scope.newMedia.author = parser.hostname
        else
            $scope.newMedia.author = $scope.user

    $scope.changeTab = (type) ->
        $scope.newMedia = GalleryService.initMediaResource(type, $scope.user)
        $scope.submitted = false
        if type == 'experience'
            $scope.newMedia.experience = {}
            $scope.mediaForm.$setValidity('mediaDefine', true)
            $scope.mediaForm.$setValidity('documentFileFormat', true)
            $scope.mediaForm.mediaUrl.$setValidity('format', true)

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || $scope.mediaForm.$pristine
            return false

        $scope.medias.push(newMedia)
        $scope.newMedia = GalleryService.initMediaResource(newMedia.type, $scope.user)
        $scope.submitted = false
        $scope.getFilterMedias()

    $scope.remove = (media) ->
        mediaIndex = $scope.medias.indexOf(media)

        if mediaIndex != -1
            $scope.medias.splice(mediaIndex, 1)
            $scope.getFilterMedias()

        else
            if $scope.projectsheet.bucket
                BucketFile.one(media.id).remove().then(->
                    fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media)
                    $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
                    $scope.getFilterMedias()
                )

        $scope.getFilterMedias()
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
                promise = new Promise((resolve, reject) ->
                    ProjectService.uploadMedia(media, $scope.projectsheet.bucket.id, $scope.projectsheet.id).then((res) ->
                        if $scope.coverId == undefined && parseInt(GalleryService.coverId) == index + 1
                            ProjectSheet.one($scope.projectsheet.id).patch({cover: res.resource_uri})
                            .then(() -> resolve())
                            .catch(() -> reject())

                        if $scope.coverId == media.id
                            ProjectSheet.one($scope.projectsheet.id).patch({cover: res.resource_uri})
                            .then(() -> resolve())
                            .catch(() -> reject())
                      )
                  )
                promises.push(promise)
            )

            Promise.all(promises).then(() ->
                $modalInstance.close($scope.projectsheet)
            ).catch((err) ->
                console.error err
            )
        else
            $modalInstance.close($scope.projectsheet)

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')
)
