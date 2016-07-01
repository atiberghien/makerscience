module = angular.module('commons.gallery.directives', [])

module.directive('galleryProject', () ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-project.directive.html',
      controller: 'GalleryCreationProjectCtrl'
    }
)

module.directive('galleryResource', () ->
    return {
      scope: true
      restrict: 'E'
      templateUrl: 'views/gallery/gallery-resource.directive.html',
      controller: 'GalleryCreationResourceCtrl'
    }
)

module.directive('checkForm', (GalleryService) ->
    return {
        require: "form"
        restrict: 'A'
        link: (scope, el) ->
            check = () ->
                if scope.newMedia.url
                    if scope.mediaForm.imageUrl then scope.mediaForm.imageUrl.$setValidity('format', true)
                    if scope.mediaForm.documentUrl then scope.mediaForm.documentUrl.$setValidity('format', true)
                    if scope.mediaForm.videoUrl then scope.mediaForm.videoUrl.$setValidity('format', true)

                    switch scope.newMedia.type
                        when 'image'
                            scope.mediaForm.imageUrl.$setValidity('format', GalleryService.isUrlImage(scope.newMedia.url))
                        when 'document'
                            scope.mediaForm.documentUrl.$setValidity('format', GalleryService.isUrlDocument(scope.newMedia.url))
                        when 'video'
                            scope.mediaForm.videoUrl.$setValidity('format', GalleryService.isUrlVideo(scope.newMedia.url))
                else
                    if scope.newMedia.file
                        scope.mediaForm.$setValidity('imageFileFormat', true)
                        scope.mediaForm.$setValidity('documentFileFormat', true)
                        switch scope.newMedia.type
                          when 'image'
                              scope.mediaForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type))
                          when 'document'
                              scope.mediaForm.$setValidity('documentFileFormat', GalleryService.isTypeDocument(scope.newMedia.file.type))


            el.bind('change', () ->
                scope.$apply ->
                    check()
            )

            scope.setTitle = (title) ->
                scope.$apply ->
                    scope.mediaForm.$setDirty()
                    scope.newMedia.title = title
                    return

            scope.changeTab = (type) ->
                scope.newMedia.type = type
                # scope.newMedia = GalleryService.initMediaProject(type)
    }
)
