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

module.directive('checkForm', (GalleryService, $http, Config) ->
    return {
        require: "form"
        restrict: 'A'
        link: (scope, el) ->
            check = () ->
                if !scope.newMedia.url && !scope.newMedia.file && !scope.newMedia.experience
                    scope.mediaForm.$setValidity('mediaDefine', false)

                if !!scope.newMedia.url
                    scope.mediaForm.$setValidity('mediaDefine', true)
                    if scope.mediaForm.imageUrl then scope.mediaForm.imageUrl.$setValidity('format', true)
                    if scope.mediaForm.documentUrl then scope.mediaForm.documentUrl.$setValidity('format', true)
                    if scope.mediaForm.videoUrl then scope.mediaForm.videoUrl.$setValidity('format', true)

                    switch scope.newMedia.type
                        when 'image'
                            scope.mediaForm.imageUrl.$setValidity('format', GalleryService.isUrlImage(scope.newMedia))
                        when 'document'
                            scope.mediaForm.documentUrl.$setValidity('format', GalleryService.isUrlDocument(scope.newMedia.url))
                        when 'video'
                            scope.mediaForm.videoUrl.$setValidity('format', GalleryService.isUrlVideo(scope.newMedia.url))

                else if !!scope.newMedia.file
                    scope.mediaForm.$setValidity('mediaDefine', true);
                    scope.mediaForm.$setValidity('imageFileFormat', true)
                    scope.mediaForm.$setValidity('documentFileFormat', true)
                    switch scope.newMedia.type
                      when 'image'
                          scope.mediaForm.$setValidity('imageFileFormat', GalleryService.isTypeImage(scope.newMedia.file.type))
                      when 'document'
                          scope.mediaForm.$setValidity('documentFileFormat', GalleryService.isTypeDocument(scope.newMedia.file.type))


            el.bind('change', () ->
                if scope.newMedia.url
                    $http.get(Config.media_uri + '/geturl/?url=' + scope.newMedia.url)
                      .then((res) ->
                          if scope.newMedia.title == ''
                              scope.newMedia.title = res.title
                          scope.newMedia.description = res.description
                          check()
                      ,(err) ->
                          scope.mediaForm.mediaUrl.$setValidity('format', false)
                          return false;
                      )
                else
                    scope.$apply ->
                        check()
            )



            scope.setTitle = (title) ->
                scope.$apply ->
                    scope.mediaForm.$setDirty()
                    scope.newMedia.title = title
                    return
    }
)
