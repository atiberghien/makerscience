module = angular.module('commons.directives.gallery')

module.directive('gallery', [ ->
    return {
        scope: {
            uploader: '='
        }
        restrict: 'E'
        templateUrl: 'views/gallery/gallery.directive.html'
        # controller: 'GalleryCreationInstanceCtrl'
        link: (scope) ->
            console.log scope
    }
])
