module = angular.module("commons.gallery.services", [])


module.factory("GalleryService", () ->
    coverIndex = null

    extensionIsValid = (url, validExtensions) ->
      ext = url.split('.').pop()
      return validExtensions.indexOf(ext) > -1

    initMediaProject = (type) ->
      media = {
        title: ''
        type: type
      }
      return media

    initMediaResource = (type) ->
        media = {
            title: ''
            type: type
            isAuthor: true
        }
        return media

    setCoverIndex = (index) ->
        this.coverIndex = if this.coverIndex != null && this.coverIndex == index then null else index
        return this.coverIndex

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

    isUrlImage = (url) ->
        extensions = ['png', 'jpg', 'gif']
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

    isTypeImage = (type) ->
      console.log type
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
      ]
      return types.indexOf(type) > -1

    return {
        initMediaProject: initMediaProject
        initMediaResource: initMediaResource
        setCoverIndex: setCoverIndex
        getVideoProvider: getVideoProvider
        isUrlImage: isUrlImage
        isUrlDocument: isUrlDocument
        isUrlVideo: isUrlVideo
        isTypeImage: isTypeImage
        isTypeDocument: isTypeDocument
        coverIndex: this.coverIndex
    }
)
