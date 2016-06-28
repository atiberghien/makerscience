module = angular.module("commons.gallery.services", [])

module.factory("GalleryService", () ->
    this.coverIndex = null

    return {

        initMediaProject: (type) ->
            media = {
                title: ''
                type: type
            }
            return media

        initMediaResource: (type) ->
            media = {
                title: ''
                type: type
                isAuthor: true
            }
            return media

        setCoverIndex: (index) ->
            this.coverIndex = if this.coverIndex != null && this.coverIndex == index then null else index
            return this.coverIndex

        coverIndex: this.coverIndex
    }
)
