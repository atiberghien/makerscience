module = angular.module("commons.graffiti.controllers", ['commons.graffiti.services'])

module.controller("TagListCtrl", ($scope, Tag) ->
    $scope.tags = Tag.getList().$object
)

module.controller("TagAutoCompleteCtrl", ($scope, $q, Tag) ->

    $scope.loadTags = (query, tags) ->
        console.log("TAGS : ", tags)
        deferred = $q.defer()
        if tags == null or tags == undefined
            tags = Tag.getList().$object
        availableTags = []
        angular.forEach(tags, (tag) ->
            if tag.name.indexOf(query) > -1
                tmpTag =
                    'text' : tag.name
                availableTags.push(tmpTag)
        )
        deferred.resolve(availableTags)
        return deferred.promise
)

module.controller("TaggedItemCtrl", ($scope, $stateParams, $modal, Tag, TaggedItem, ObjectProfileLink) ->

    $scope.taggedItems = []
    $scope.tag = null

    if $stateParams.slug
        Tag.one().get({slug:$stateParams.slug}).then((tagResult) ->
            $scope.tag = tagResult.objects[0]
            if $scope.tag && $scope.tag.weight > 0
                $scope.taggedItems = TaggedItem.getList({'tag__slug' : $stateParams.slug}).$object
        )

        $scope.followTag = (profileID) ->
            ObjectProfileLink.one().customPOST(
                profile_id: profileID,
                level: 51,
                detail : '',
                isValidated:true
            , 'tag/'+$scope.tag.id)


    $scope.addTag = (objectTypeName, resourceId, tag) ->
        TaggedItem.one().customPOST({tag : tag.text}, objectTypeName+"/"+resourceId, {})

    $scope.removeTag = (tag) ->
        TaggedItem.one(tag.taggedItemId).remove()

    $scope.openTagPopup =  (editTag, taggedObject, taggedObjectTypeName)->
        modalInstance = $modal.open(
            templateUrl: 'views/catalog/block/modal_tags.html'
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
