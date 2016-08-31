module = angular.module("commons.tags.controllers", [])

module.controller("TagListCtrl", ($scope, Tag) ->
    $scope.tags = Tag.getList().$object
)

module.controller("TagAutoCompleteCtrl", ($scope, Tag) ->

    $scope.loadTags = (query) ->
        Tag.getList({'slug__icontains': query}).then((tagResults) ->
            availableTags = []
            angular.forEach(tagResults, (tag) ->
                tmpTag =
                    'text' : tag.name
                    'weight' : tag.weight
                availableTags.push(tmpTag)
            )
            return availableTags
        )
)

# module.controller("TaggedItemCtrl", ($scope, $stateParams, $modal, TaggedItem) ->
#
#     # $scope.addTag = (objectTypeName, resourceId, tag) ->
#     #     TaggedItem.one().customPOST({tag : tag.text}, objectTypeName+"/"+resourceId, {})
#     #
#     # $scope.removeTag = (tag) ->
#     #     TaggedItem.one(tag.taggedItemId).remove()
#
#     $scope.openTagPopup =  (preparedTags, tagType, editableTag, addTagCallback, removeTagCallback)->
#         modalInstance = $modal.open(
#             templateUrl: '/views/block/modal_tags.html'
#             controller: 'TagPopupCtrl'
#             size: 'lg'
#             resolve :
#                 params : ->
#                     return {
#                         preparedTags : preparedTags
#                         tagType : tagType
#                         editableTag : editableTag
#                         addTag : addTagCallback
#                         removeTag : removeTagCallback
#                         }
#         )
#
# )

module.controller('TagPopupCtrl', ($scope, $modalInstance, params) ->
    $scope.preparedTags = params.preparedTags
    $scope.editableTag = params.editableTag
    if $scope.editableTag
        $scope.tagType = params.tagType
        $scope.addTag = params.addTag
        $scope.removeTag = params.removeTag

    $scope.ok = ->
        $modalInstance.close()

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')
)
