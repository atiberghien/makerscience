module = angular.module("commons.tags.services", ['restangular'])


# Services
module.factory('Tag', (Restangular) ->
    return Restangular.service('tag')
)
module.factory('TaggedItem', (Restangular) ->
    return Restangular.service('taggeditem')
)

module.factory("TaggedItemService", ($modal, TaggedItem) ->

    # $scope.addTag = (objectTypeName, resourceId, tag) ->
    #     TaggedItem.one().customPOST({tag : tag.text}, objectTypeName+"/"+resourceId, {})
    #
    # $scope.removeTag = (tag) ->
    #     TaggedItem.one(tag.taggedItemId).remove()
    TaggedItemService = {}

    TaggedItemService.openTagPopup = (preparedTags, tagType, editableTag, addTagCallback, removeTagCallback)->
        modalInstance = $modal.open(
            templateUrl: '/views/block/modal_tags.html'
            controller: 'TagPopupCtrl'
            size: 'lg'
            resolve :
                params : ->
                    return {
                        preparedTags : preparedTags
                        tagType : tagType
                        editableTag : editableTag
                        addTag : addTagCallback
                        removeTag : removeTagCallback
                        }
        )

    return TaggedItemService
)
