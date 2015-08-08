module = angular.module("commons.graffiti.controllers", ['commons.graffiti.services'])

module.controller("TagListCtrl", ($scope, Tag) ->
    $scope.tags = Tag.getList().$object
)

module.controller("TagAutoCompleteCtrl", ($scope, Tag) ->

    $scope.loadTags = (query) ->
        return Tag.getList().then((tagResults) ->
            availableTags = []
            angular.forEach(tagResults, (tag) ->
                if tag.name.indexOf(query) > -1
                    tmpTag =
                        'text' : tag.name
                    availableTags.push(tmpTag)
            )
            return availableTags
        )
)

module.controller("TaggedItemCtrl", ($scope, $stateParams, $modal, TaggedItem) ->

    $scope.addTag = (objectTypeName, resourceId, tag) ->
        TaggedItem.one().customPOST({tag : tag.text}, objectTypeName+"/"+resourceId, {})

    $scope.removeTag = (tag) ->
        TaggedItem.one(tag.taggedItemId).remove()

    $scope.openTagPopup =  (editTag, taggedObject, taggedObjectTypeName)->
        modalInstance = $modal.open(
            templateUrl: '/views/catalog/block/modal_tags.html'
            controller: 'TagPopupCtrl'
            size: 'lg'
            resolve :
                params : ->
                    return {
                        preparedTags : $scope.preparedTags
                        editTag : editTag
                        objectTypeName : taggedObjectTypeName
                        taggedObject : taggedObject
                        addTag : $scope.addTag
                        removeTag : $scope.removeTag
                        }
        )

)

module.controller('TagPopupCtrl', ($scope, $modalInstance, params) ->
    $scope.preparedTags = params.preparedTags
    $scope.editTag = params.editTag
    if $scope.editTag
        $scope.objectTypeName = params.objectTypeName
        $scope.taggedObject = params.taggedObject
        $scope.addTag = params.addTag
        $scope.removeTag = params.removeTag

    $scope.ok = ->
        $modalInstance.close()

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')
)
