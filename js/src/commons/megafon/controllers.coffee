module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("PostCreateCtrl", ($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) ->
    $scope.questionTags = []

    $scope.savePost = (newPost, parent, authorProfile) ->
        if parent
            newPost["parent"] = parent.resource_uri

        return Post.post(newPost).then((postResult) ->
            angular.forEach($scope.questionTags, (tag)->
                TaggedItem.one().customPOST({tag : tag.text}, "post/"+postResult.id, {})
            )

            ObjectProfileLink.one().customPOST(
                profile_id: authorProfile.id,
                level: 30 ,
                detail : "Auteur du post #"+postResult.id,
                isValidated:true
            , 'post/'+ postResult.id)

            if parent
                ObjectProfileLink.one().customPOST(
                    profile_id: authorProfile.id,
                    level: 31,
                    detail : "Contributeur du post #"+postResult.id,
                    isValidated:true
                , 'post/'+parent.id)

            return postResult
        )
)
module.controller("PostCtrl", ($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) ->

    $scope.getContributors = (postID) ->
        ##contributors
        $scope["contributors"+postID] = []
        contributorsIdx = []
        ObjectProfileLink.one().customGET('post/'+postID, {level:31}).then((objectProfileLinkResults) ->
            angular.forEach(objectProfileLinkResults.objects, (objectProfileLink) ->
                if contributorsIdx.indexOf(objectProfileLink.profile.id) == -1
                    contributorsIdx.push(objectProfileLink.profile.id)
                    $scope["contributors"+postID].push(objectProfileLink.profile)
            )
            return $scope["contributors"+postID]
        )

    $scope.getSimilars = (postID) ->
        $scope["similars"+postID] = []
        TaggedItem.one().customGET("post/"+postID+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'post'
                    Post.one(similar.id).get().then((postResult)->
                        $scope["similars"+postID].push(postResult)
                    )
            )
            return $scope["similars"+postID]
        )


    $scope.getPostAuthor = (postID) ->
        return ObjectProfileLink.one().customGET('post/'+postID, {level:30}).then((objectProfileLinkResults) ->
            if objectProfileLinkResults.objects.length == 1
                $scope["post"+postID+"Author"] = objectProfileLinkResults.objects[0].profile
            else
                $scope["post"+postID+"Author"] = null
            return $scope["post"+postID+"Author"]
        )

    $scope.fetchAuthors = (post) ->
        $scope.getPostAuthor(post.id).then((author)->
            post.author = author
            angular.forEach(post.answers, (answer) ->
                $scope.fetchAuthors(answer)
            )
        )

    $scope.fetchContributors = (post) ->
        $scope.getContributors(post.id).then((contributors) ->
            post.contributors = contributors
            angular.forEach(post.answers, (answer) ->
                $scope.fetchContributors(answer)
            )
        )

    $scope.getLikes = (postID) ->
        return ObjectProfileLink.one().get(
            level: 34,
            content_type : 'post'
            object_id : postID)

    $scope.fetchPostLikes = (post) ->
        $scope.getLikes(post.id).then((likes) ->
            post.likes = likes.objects
            angular.forEach(post.answers, (answer) ->
                $scope.fetchPostLikes(answer)
            )
        )
)
