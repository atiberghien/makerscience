module = angular.module("makerscience.forum.controllers", ["commons.megafon.controllers",
                                                           'makerscience.base.services','makerscience.base.controllers'])



module.controller("MakerSciencePostListCtrl", ($scope, $controller, MakerSciencePost) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.threads = MakerSciencePost.one().customGETLIST('search', $scope.params).$object

    $scope.$emit('post:new', $scope.refreshList);

)

module.controller("MakerSciencePostCreateCtrl", ($scope, $controller, TaggedItem, ObjectProfileLink, MakerSciencePost, MakerScienceProject, MakerScienceResource, DataSharing) ->
    angular.extend(this, $controller('PostCreateCtrl', {$scope: $scope}))

    $scope.allAvailableItems = []
    $scope.linkedItems= []

    MakerScienceProject.getList().then((projectResults)->
        angular.forEach(projectResults, (project) ->
            $scope.allAvailableItems.push(
                fullObject: project
                title : "[Projet] " + project.parent.title
                type : 'project'
            )
        )
    )

    MakerScienceResource.getList().then((resourceResults)->
        angular.forEach(resourceResults, (resource) ->
            $scope.allAvailableItems.push(
                fullObject: resource
                title : "[Ressource] " + resource.parent.title
                type : 'resource'
            )
        )
    )

    $scope.delLinkedItem = (item) ->
        itemIndex = $scope.linkedItems.indexOf(item)
        $scope.linkedItems.pop(itemIndex)

    $scope.addLinkedItem = (newLinkedItem) ->
        item = newLinkedItem.originalObject
        if newLinkedItem && $scope.linkedItems.indexOf(item) < 0
            $scope.linkedItems.push(item)
            $scope.newLinkedItem = null
            $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea')

    $scope.saveMakersciencePost = (newPost, parent, authorProfile) ->
        $scope.savePost(newPost, parent, authorProfile).then((newPostURI)->
            makerSciencePost =
                parent : newPostURI,
                post_type : newPost.type
                linked_projects : []
                linked_resources : []

            angular.forEach($scope.questionTags, (tag)->
                TaggedItem.one().get({content_type : 'post', object_id : newPost.id, tag__slug : tag.text}).then((taggedItemResults) ->
                    if taggedItemResults.objects.length == 1
                        taggedItem = taggedItemResults.objects[0]
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItem.id)
                )
            )

            angular.forEach($scope.linkedItems, (item) ->
                makerSciencePost["linked_"+item.type+"s"].push(item.fullObject.resource_uri)
            )

            MakerSciencePost.post(makerSciencePost).then((newMakerSciencePostResult) ->
                return false
            )
        )
)


module.controller("MakerSciencePostCtrl", ($scope, $stateParams, $controller, MakerSciencePost, DataSharing) ->
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))
    angular.extend(this, $controller('CommunityCtrl', {$scope: $scope}))

    MakerSciencePost.one().get({parent__slug: $stateParams.slug}).then((makerSciencePostResult)->
        $scope.post = makerSciencePostResult.objects[0]
        $scope.initFromID($scope.post.parent.id)
        DataSharing.sharedObject['post'] = $scope.post.parent
        $scope.init('post')
    )
)

module.controller("MakerSciencePostEmbedCtrl", ($scope, $controller, MakerSciencePost) ->
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))

    $scope.init = (postID) ->
        MakerSciencePost.one(postID).get().then((makerSciencePostResult)->
            $scope.post = makerSciencePostResult
            $scope.initFromID($scope.post.parent.id)
    )
)
