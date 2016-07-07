module = angular.module('commons.directives.thumb', [])

module.directive('ngThumb', ['$window', 'GalleryService', ($window, GalleryService) ->
    helper = {
        support: !!($window.FileReader && $window.CanvasRenderingContext2D),
        isFile: (item) ->
            return angular.isObject(item) && item instanceof $window.File
        isImage: (file) ->
            return GalleryService.isTypeImage(file.type)
    }

    return {
        restrict: 'E'
        scope: {
            params: '='
        }
        template: '<canvas/>'
        link: (scope, element, attributes) ->
            if !helper.support
                return

            canvas = element.find('canvas')
            reader = new FileReader()

            reader.onload = (event) ->
                img = new Image()
                img.onload = () ->
                    width = scope.params.width || this.width / this.height * scope.params.height
                    height = scope.params.height || this.height / this.width * scope.params.width
                    canvas.attr({ width: width, height: height })
                    canvas[0].getContext('2d').drawImage(this, 0, 0, width, height)
                img.src = event.target.result

            scope.$watch('params', () ->
                if !helper.isFile(scope.params.file)
                    return
                if !helper.isImage(scope.params.file)
                    return
                reader.readAsDataURL(scope.params.file)
            )

            element.bind('change', (changeEvent) ->
                if !helper.isFile(scope.params.file)
                    return
                if !helper.isImage(scope.params.file)
                    return
                reader.readAsDataURL(scope.params.file)
            )
    }
]);
