module = angular.module('commons.directives.gallery', [])

module.directive('galleryForm', [ ->
    return {
      scope: {
          cancelAction: '&'
          uploader: '='
      }
      restrict: 'E'
      templateUrl: 'views/gallery-form/gallery-form.html'
      link: (scope, ProjectSheet) ->
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

          scope.videos = {}
          scope.coverCandidateQueueIndex = null


          # scope.uploader = $rootScope.uploader

          # scope.ok = ->
          #     $modalInstance.close({
          #         coverCandidateQueueIndex : scope.coverCandidateQueueIndex,
          #         videos : scope.videos
          #     })

          scope.cancel = ->
              scope.uploader.clearQueue()
              # $modalInstance.dismiss('cancel')

          scope.isCoverCandidate = (fileItem) ->
              fileQueueIndex = scope.uploader.getIndexOfItem(fileItem)
              return scope.coverCandidateQueueIndex != null && scope.coverCandidateQueueIndex == fileQueueIndex

          scope.toggleCoverCandidate = (fileItem) ->
              if scope.isCoverCandidate(fileItem)
                  scope.coverCandidateQueueIndex = null
              else
                  scope.coverCandidateQueueIndex = scope.uploader.getIndexOfItem(fileItem)

          scope.addMedia = (media) ->
              ProjectSheet.one(projectsheetResult.id).patch({videos:scope.projectsheet.videos})

              scope.uploader.onBeforeUploadItem = (item) ->
                  item.formData.push(
                      bucket : projectsheetResult.bucket.id
                  )
                  item.headers =
                     Authorization : scope.uploader.headers["Authorization"]

              scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
                  if scope.uploader.getIndexOfItem(fileItem) == scope.coverIndex
                      ProjectSheet.one(projectsheetResult.id).patch({cover:response.resource_uri})

              scope.uploader.onCompleteAll = () ->
                  console.log('complete all')

              scope.uploader.uploadAll()


          scope.addVideo = (newVideoURL) ->
              scope.videos[newVideoURL] = null

          scope.delVideo = (videoURL) ->
              delete scope.videos[videoURL]


    }
])
