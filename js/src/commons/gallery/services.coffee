module = angular.module("commons.gallery.services", [])


module.factory("GalleryService", () ->
    coverId = null

    extensionIsValid = (url, validExtensions) ->
      ext = url.split('.').pop()
      return validExtensions.indexOf(ext) > -1

    initMediaProject = (type) ->
      uniqueId = _.uniqueId()
      media = {
        id: uniqueId
        title: ''
        type: type
      }
      return media

    initMediaResource = (type, author) ->
        uniqueId = _.uniqueId()
        media = {
            id: uniqueId
            title: ''
            type: type
            is_author: true
            author: author
        }
        return media

    setCoverId = (id) ->
        this.coverId = if this.coverId != null && this.coverId == id then null else id
        return this.coverId

    getVideoProvider = (url) ->
        youtube = 'youtube.com'
        youtube_short = 'youtu.be'
        dailymotion = 'dai.ly'

        if url.indexOf(youtube) > -1 || url.indexOf(youtube_short) > -1
            return 'youtube'
        else if url.indexOf(dailymotion) > -1
            return 'dailymotion'
        else
            return null

    isUrlImage = (media) ->
        url = if media.url then media.url else  media.file.name
        extensions = ['png', 'jpg', 'gif', 'jpeg']
        return extensionIsValid(url, extensions)

    isUrlDocument = (url) ->
        extensions = [
          'doc', 'docx', 'pdf', 'ppt'
          'xls', 'xlc', 'xlr'
          'odt', 'odb', 'odc', 'odf', 'odg', 'odp', 'ods', 'odt'
        ]
        return extensionIsValid(url, extensions)

    isUrlVideo = (url) ->
      if getVideoProvider(url) != null
        return true

    isUrl = (url) ->
        pattern = new RegExp(/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/)
        return pattern.test(url)

    isTypeImage = (type) ->
      types = [
        'image/png'
        'image/jpeg'
        'image/gif'
      ]
      return types.indexOf(type) > -1

    isTypeDocument = (type) ->
      types = [
        'application/pdf'
        'application/vnd.oasis.opendocument.text'
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        'application/vnd.openxmlformats-officedocument.wordprocessingml.template'
        'application/msword'
        'application/zip'
        'application/x-compressed-zip'
        'text/x-markdown'
        'text/plain'
        'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        'application/vnd.ms-powerpointtd'
        'image/png'
        'image/jpeg'
        'image/gif'
      ]
      return types.indexOf(type) > -1

    return {
        initMediaProject: initMediaProject
        initMediaResource: initMediaResource
        setCoverId: setCoverId
        getVideoProvider: getVideoProvider
        isUrlImage: isUrlImage
        isUrlDocument: isUrlDocument
        isUrlVideo: isUrlVideo
        isUrl: isUrl
        isTypeImage: isTypeImage
        isTypeDocument: isTypeDocument
        coverId: this.coverId
    }
)
