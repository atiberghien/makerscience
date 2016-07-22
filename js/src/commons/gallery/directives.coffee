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

module.directive('checkForm', (GalleryService, MediaRestangular) ->
    return {
        require: "form"
        restrict: 'A'
        link: (scope, el) ->
            check = () ->
                if scope.newMedia.url
                    scope.mediaForm.$setValidity('mediaDefine', true);
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
                        when 'link'
                            scope.mediaForm.mediaUrl.$setValidity('format', GalleryService.isUrl(scope.newMedia.url))
                else if scope.newMedia.file
                    scope.mediaForm.$setValidity('mediaDefine', true);
                    scope.mediaForm.$setValidity('imageFileFormat', true)
                    scope.mediaForm.$setValidity('documentFileFormat', true)
                    switch scope.newMedia.type
                      when 'image'
                          scope.mediaForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type))
                      when 'document'
                          scope.mediaForm.$setValidity('documentFileFormat', GalleryService.isTypeDocument(scope.newMedia.file.type))

                else
                    scope.mediaForm.$setValidity('mediaDefine', false);

            scope.mediaForm.$setValidity('mediaDefine', false);

            el.bind('change', () ->
                scope.$apply ->
                    check()

                if scope.newMedia.url
                    MediaRestangular.one('geturl').get({'url': scope.newMedia.url})
                      .then((res) ->
                          scope.newMedia.title = res.title
                          scope.newMedia.description = res.description
                      )
                      .catch((err) ->
                          console.error err
                      )
            )



            scope.setTitle = (title) ->
                scope.$apply ->
                    scope.mediaForm.$setDirty()
                    scope.newMedia.title = title
                    return
    }
)
