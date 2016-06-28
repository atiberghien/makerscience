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
        link: (scope, el) ->
            el.bind('change', () ->
                scope.$apply ->
                    if scope.newMedia.url
                        switch scope.newMedia.type
                            when 'image' then scope.mediaForm.imageUrl.$setValidity('format', GalleryService.isUrlImage(scope.newMedia.url))
                            when 'document' then scope.mediaForm.documentUrl.$setValidity('format', GalleryService.isUrlDocument(scope.newMedia.url))
                            when 'video' then scope.mediaForm.videoUrl.$setValidity('format', GalleryService.isUrlVideo(scope.newMedia.url))
                    else
                        switch scope.newMedia.type
                          when 'image' then scope.mediaForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type))
                          when 'document' then scope.mediaForm.$setValidity('documentFileFormat', GalleryService.isTypeDocument(scope.newMedia.file.type))
            )
    }
)
