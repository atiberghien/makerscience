module = angular.module('commons.gallery.directives', [])

module.directive('galleryForm', [ ->
    return {
        scope: {
            cancelAction: '&'
        }
        restrict: 'E'
        templateUrl: 'views/gallery-form/gallery-form.html'
        controller: 'GalleryCreationInstanceCtrl'
        link: () ->

    }
])
