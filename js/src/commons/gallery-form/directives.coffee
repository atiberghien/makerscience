module = angular.module('commons.directives.gallery', [])

module.directive('galleryForm', (FormService, BucketFile, ProjectSheet) ->
    return {
      scope: {
          cancelAction: '&'
          uploader: '='
          projectsheet: '='
          coverIndex:"="
      }
      restrict: 'E'
      templateUrl: 'views/gallery-form/gallery-form.directive.html'
      link: (scope) ->
          scope.newMedia = {
              title: 'title'
          }

          scope.setTitle = (title) ->
              scope.$apply ->
                scope.newMedia.title = title
                return

          scope.tabSelect = (type) ->
              scope.newMedia = {
                title: ''
                type: type
              }

          scope.config = config

          scope.hideControls = false

          if !scope.projectsheet.videos
              scope.projectsheet.videos = {}
          scope.videos = scope.projectsheet.videos

          scope.uploader.removeAfterUpload = true
          scope.uploader.onBeforeUploadItem = (item) ->
              item.formData.push(
                  bucket : scope.projectsheet.bucket.id
              )
              item.headers =
                 Authorization : scope.uploader.headers["Authorization"]

          # must use tmp var in order to not modify queue during cover candidate saving ... sync issue
          # scope.tmpBucketFiles = []
          scope.tmpNewCover = null

          scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
              if scope.isCoverCandidate(fileItem)
                  scope.tmpNewCover = response
              # scope.tmpBucketFiles.push(response)
              scope.projectsheet.bucket.files.push(response)

          scope.uploader.onCompleteAll = () ->
              console.log 'complete all'
              console.log scope.uploader
          #     console.log 'onCompleteAll'
          #     console.log scope.uploader.queue
          #     if scope.tmpNewCover
          #         scope.toggleCover(scope.tmpNewCover).then(->
          #             angular.forEach(scope.tmpBucketFiles, (file) ->
          #                 scope.projectsheet.bucket.files.push(file)
          #             )
          #         )
          #     else
          #         angular.forEach(scope.tmpBucketFiles, (file) ->
          #             scope.projectsheet.bucket.files.push(file)
          #         )

          scope.addMedia = ->
              if scope.uploader.queue.length > 0
                  scope.uploader.uploadAll()
                  console.log 'upload all'
              else
                  scope.uploader.onCompleteAll()
                  console.log scope.uploader.getNotUploadedItems()
                  scope.uploader.onProgressItem = () ->
                      console.log 'in progress'

          scope.cancel = ->
              scope.uploader.clearQueue()

          scope.removePicture = (file) ->
              if scope.isCover(file)
                  scope.toggleCover(file) #reset cover

              BucketFile.one(file.id).remove().then(->
                  fileBucketIndex = scope.projectsheet.bucket.files.indexOf(file)
                  scope.projectsheet.bucket.files.splice(fileBucketIndex, 1)
              )

          scope.isCoverCandidate = (fileItem) ->
              fileQueueIndex = scope.uploader.getIndexOfItem(fileItem)
              return scope.coverIndex != null && scope.coverIndex == fileQueueIndex

          scope.isCover = (file) ->
              if !scope.projectsheet.cover
                scope.projectsheet.cover = FormService.projectsheetResult.cover
              return scope.projectsheet.cover != null && scope.projectsheet.cover.id == file.id

          scope.toggleCoverCandidate = (fileItem) ->
              if scope.isCoverCandidate(fileItem)
                  scope.coverIndex = null
              else
                  scope.coverIndex = scope.uploader.getIndexOfItem(fileItem)

          scope.toggleCover = (file) ->
              if scope.isCover(file)
                  scope.projectsheet.cover = null
                  return ProjectSheet.one(scope.projectsheet.id).patch({cover:null})
              else
                  scope.projectsheet.cover = file
                  return ProjectSheet.one(scope.projectsheet.id).patch({cover:file.resource_uri})

          scope.addVideo = (newVideoURL) ->
              scope.projectsheet.videos[newVideoURL] = null
              scope.videos[newVideoURL] = null # just for display concerns
              ProjectSheet.one(scope.projectsheet.id).patch({videos:scope.projectsheet.videos})

          scope.delVideo = (videoURL) ->
              delete scope.projectsheet.videos[videoURL]
              delete scope.videos[videoURL] # just for display concerns
              ProjectSheet.one(scope.projectsheet.id).patch({videos:scope.projectsheet.videos})

    }
)
