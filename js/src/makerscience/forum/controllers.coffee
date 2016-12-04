module = angular.module("makerscience.forum.controllers", ["commons.megafon.controllers",
                                                           'makerscience.base.services','makerscience.base.controllers'])


module.controller("MentionCtrl", ($scope, MakerScienceProfile) ->
    $scope.people = []

    $scope.initMention = (iframeElement) ->
        $scope.tinyMceOptions["init_instance_callback"] = (editor) ->
            $scope[iframeElement] = editor.iframeElement

    $scope.searchPeople = (mentionTerm) ->
        if mentionTerm.length > 2
            MakerScienceProfile.one().customGETLIST('search', {q : '*'+mentionTerm+'*'}).then((makerScienceProfileResults) ->
                $scope.people = makerScienceProfileResults
            )

    $scope.getPeopleTextRaw = (mentionnedProfile) ->
        return "@" + mentionnedProfile.slug
)

module.controller("MakerSciencePostCreateCtrl", ($scope, $controller, $filter, MakerSciencePost, MakerScienceProfile, ObjectProfileLink,  MakerScienceProjectLight, MakerScienceResourceLight, TaggedItem) ->
    angular.extend(this, $controller('PostCreateCtrl', {$scope: $scope}))

    $scope.allAvailableItems = []

    MakerScienceProjectLight.getList().then((projectResults)->
        angular.forEach(projectResults, (project) ->
            $scope.allAvailableItems.push(
                fullObject: project
                title : "[Projet] " + project.title
                type : 'project'
            )
        )
    )

    MakerScienceResourceLight.getList().then((resourceResults)->
        angular.forEach(resourceResults, (resource) ->
            $scope.allAvailableItems.push(
                fullObject: resource
                title : "[Ressource] " + resource.title
                type : 'resource'
            )
        )
    )

    $scope.linkedItems= []
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
        $scope.savePost(newPost, parent, authorProfile).then((newPost)->
            makerSciencePost =
                parent : newPost.resource_uri,
                post_type : newPost.type || 'message'
                linked_projects : newPost.linked_projects || []
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

            return MakerSciencePost.post(makerSciencePost).then((newMakerSciencePostResult) ->
                mentions = newMakerSciencePostResult.parent.text.match(/\B@[a-z0-9_-]+/gi)
                angular.forEach(mentions, (mention) ->
                    profileSlug = mention.substr(1)
                    MakerScienceProfile.one().get({slug:profileSlug}).then((makerScienceProfileResults) ->
                        if makerScienceProfileResults.objects.length == 1
                            ObjectProfileLink.one().customPOST(
                                profile_id: $scope.currentMakerScienceProfile.parent.id,
                                level: 41,
                                detail : profileSlug,
                                isValidated:true
                            , 'makersciencepost/'+newMakerSciencePostResult.id)
                    )
                )
                return newMakerSciencePostResult
            )
        )
)


module.controller("MakerScienceForumCtrl", ($scope,  $state, $controller, $filter,
                                                MakerSciencePostLight, MakerScienceProfile,
                                                DataSharing, ObjectProfileLink, TaggedItem, CurrentMakerScienceProfileService) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))
    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))

    # $scope.showCreateButton = false
    $scope.newPost = {
        title : '',
        text : '',
        type : 'message'
    }
    $scope.params["limit"] = $scope.limit =  6

    $scope.refreshList = () ->
        MakerSciencePostLight.one().customGETLIST('search', $scope.params).then((makerSciencePostResults) ->
            meta = makerSciencePostResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.threads =  makerSciencePostResults
        )

    # Must be called AFTER refreshList definition due to inheriance
    $scope.initMakerScienceAbstractListCtrl()


    $scope.fetchRecentPosts = () ->
        $scope.params['ordering'] = '-updated_on'
        $scope.refreshList()

    $scope.fetchTopPosts = () ->
        $scope.params['ordering'] = '-answers_count'
        $scope.refreshList()


    $scope.fetchRecentPosts()

    $scope.inlineSaveMakersciencePost = (newPost) ->
        $scope.errors = []
        if $scope.newPost.title == ""
            $scope.errors.push("title")
        if String($scope.newPost.text).replace(/<[^>]+>/gm, '') == ""
            $scope.errors.push("text")

        if $scope.errors.length == 0
            $scope.saveMakersciencePost(newPost, null, $scope.currentMakerScienceProfile.parent).then((newMakerSciencePostResult)->
                $scope.refreshList()
                $scope.showCreateButton = false
                $scope.newPost = {
                    title : '',
                    text : '',
                    type : 'message'
                }
            )

)


module.controller("MakerSciencePostCtrl", ($scope, $state, $stateParams, $controller, $filter, MakerSciencePost, MakerScienceProfile, ObjectProfileLink, DataSharing) ->
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))
    angular.extend(this, $controller('PostCreateCtrl', {$scope: $scope}))
    angular.extend(this, $controller('CommunityCtrl', {$scope: $scope}))

    resolveMentions = (post) ->
        mentions = post.text.match(/\B@[a-z0-9_-]+/gi)
        angular.forEach(mentions, (mention) ->
            profileSlug = mention.substr(1)
            MakerScienceProfile.one().get({slug:profileSlug}).then((makerScienceProfileResults) ->
                if makerScienceProfileResults.objects.length == 1
                    profile = makerScienceProfileResults.objects[0]
                    profileRoute = $state.href("profile.detail", { slug: profile.slug})
                    profileAnchor = "<a href='"+profileRoute+"'>"+profile.full_name+"</a>"
                else
                    profileAnchor = mention
                 post.text =  post.text.replace(mention, profileAnchor)
            )
        )
        angular.forEach(post.answers, (answer) ->
            return resolveMentions(answer)
        )
        return true

    MakerSciencePost.one().get({parent__slug: $stateParams.slug}).then((makerSciencePostResult)->
        if makerSciencePostResult.objects.length == 0
            $state.go('404')
        $scope.post = makerSciencePostResult.objects[0]

        $scope.fetchAuthors($scope.post.parent)
        $scope.fetchContributors($scope.post.parent)
        $scope.getSimilars($scope.post.parent.id)
        $scope.fetchPostLikes($scope.post.parent)
        resolveMentions($scope.post.parent)

        ObjectProfileLink.one().customGETLIST('post/' + $scope.post.parent.id).then((community) ->
            $scope.contributors = []
            $scope.followers = []

            alreadyHasProfileMember = (list, profile) ->
                for value in list
                    if profile.id == value.profile.id
                        return true
                return false

            angular.forEach(community, (value, key) ->
                if value.level in [30, 31] and not alreadyHasProfileMember($scope.contributors, value.profile)
                    $scope.contributors.push(value)
                else if value.level == 32 and not alreadyHasProfileMember($scope.followers, value.profile)
                    $scope.followers.push(value)
            )
        )#for community block

        $scope.$watch('currentMakerScienceProfile', (newValue, oldValue) ->
            if newValue != null and newValue != undefined
                $scope.fetchCurrentProfileLikes = (post) ->
                    ObjectProfileLink.one().get(
                        level: 34,
                        profile_id : $scope.currentMakerScienceProfile.parent.id
                        content_type : 'post'
                        object_id : post.id).then((results) ->
                            if results.objects.length == 1
                                post.currentProfileLike = results.objects[0]
                            else
                                post.currentProfileLike = null
                            angular.forEach(post.answers, (answer) ->
                                $scope.fetchCurrentProfileLikes(answer)
                            )
                        )
                $scope.fetchCurrentProfileLikes($scope.post.parent)

                $scope.likePost = (post) ->
                    ObjectProfileLink.one().customPOST(
                        profile_id: $scope.currentMakerScienceProfile.parent.id,
                        level: 34,
                        detail : '',
                        isValidated:true
                    , 'post/'+post.id).then(->
                        $scope.fetchPostLikes(post)
                        $scope.fetchCurrentProfileLikes(post)
                    )
                $scope.unlikePost = (post) ->
                    ObjectProfileLink.one(post.currentProfileLike.id).remove().then(->
                        $scope.fetchPostLikes(post)
                        $scope.fetchCurrentProfileLikes(post)
                    )
        )
    )

    $scope.saveMakersciencePostAnswer = (newAnswer, parent, authorProfile) ->
        $scope.savePost(newAnswer, parent, authorProfile).then((newAnswer)->
            newAnswer.author = authorProfile
            mentions = newAnswer.text.match(/\B@[a-z0-9_-]+/gi)
            angular.forEach(mentions, (mention) ->
                profileSlug = mention.substr(1)
                MakerScienceProfile.one().get({slug:profileSlug}).then((makerScienceProfileResults) ->
                    if makerScienceProfileResults.objects.length == 1
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 41,
                            detail : profileSlug,
                            isValidated:true
                        , 'post/'+newAnswer.id)
                )
            )
            resolveMentions(newAnswer)
            parent.answers_count++
            parent.answers.push(newAnswer)
        )
)
