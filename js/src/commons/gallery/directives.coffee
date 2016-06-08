module = angular.module('commons.gallery.directives')

module.directive('gallery', [ ->
    return {
        scope: {
            uploader: '='
        }
        restrict: 'E'
        templateUrl: 'views/gallery/gallery.html'
        # controller: 'GalleryCreationInstanceCtrl'
        link: (scope) ->
            console.log scope
    }
])
