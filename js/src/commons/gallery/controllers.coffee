module = angular.module('commons.gallery.controllers', [])

module.controller('GalleryCreationProjectCtrl', ($scope, GalleryService, ProjectSheet, BucketFile) ->
    $scope.config = config
    $scope.newMedia = GalleryService.initMediaProject('image')

    $scope.coverId = if $scope.projectsheet.cover then $scope.projectsheet.cover.id else null
    GalleryService.setCoverId($scope.coverId)

    $scope.changeTab = (type) ->
        $scope.newMedia.type = type

    $scope.toggleCoverCandidate = (media) ->
        $scope.coverId = GalleryService.setCoverId(media.id)

        if $scope.projectsheet.id
            $scope.projectsheet.cover = media
            ProjectSheet.one($scope.projectsheet.id).patch({cover: media.resource_uri})

    $scope.addMedia = (newMedia) ->
        if $scope.mediaForm.$invalid || $scope.mediaForm.$pristine
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

module.controller('GalleryCreationResourceCtrl', (@$rootScope, $scope, $filter, GalleryService, ProjectSheet, CurrentMakerScienceProfileService) ->
    $scope.config = config
    user = @$rootScope.authVars.user
    $scope.user = user.first_name + ' ' + user.last_name
    $scope.newMedia = GalleryService.initMediaResource('document', $scope.user)

    $scope.getFilterMedias = () ->
        $scope.mediasToShow = if $scope.projectsheet.bucket then $scope.medias.concat($scope.projectsheet.bucket.files) else $scope.medias
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

        else
            if $scope.projectsheet.bucket
                BucketFile.one(media.id).remove().then(->
                    fileBucketIndex = $scope.projectsheet.bucket.files.indexOf(media)
                    $scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
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

                promise = ProjectService.uploadMedia(media, $scope.projectsheet.bucket.id, $scope.projectsheet.id)
                promises.push(promise)

                promise.then((res) ->
                    if $scope.coverId != null
                        ProjectSheet.one($scope.projectsheet.id).patch({cover: res.resource_uri})
                  )
            )

            Promise.all(promises).then(() ->
                $modalInstance.close($scope.projectsheet)
            ).catch((err) ->
                console.error err
            )
        else
            $modalInstance.dismiss()

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')
)
