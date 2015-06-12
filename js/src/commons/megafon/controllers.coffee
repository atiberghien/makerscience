module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("ThreadListCtrl", ($scope, $q, Post, ObjectProfileLink, DataSharing) ->
    $scope.ordering = {'order_by' : '-updated_on'}

    $scope.init = (orderBy) ->
        if orderBy
            $scope.ordering = orderBy
        Post.one().customGET('questions', $scope.ordering).then((postResults) ->
            $scope.threads = postResults.objects
        )

    $scope.$watch(
        ()->
            return DataSharing.sharedObject
        ,(newVal, oldVal) ->
            if DataSharing.sharedObject.hasOwnProperty('newThread')
                $scope.init()
                delete DataSharing.sharedObject["newThread"]
    )

    $scope.bestContributors = [];
    $scope.getBestContributors =  ->
        deferred = $q.defer();
        promise = deferred.promise;
        promise.then(->
            ObjectProfileLink.one().customGET('post/best', {level:[30,31,32]}).then((objectProfileLinkResults) ->
                objectProfileLinkResults.objects.forEach((objectProfileLink) ->
                    $scope.bestContributors.push(objectProfileLink)
                )
            )
        )
        deferred.resolve();
)

module.controller("PostCreateCtrl", ($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) ->
    $scope.questionTags = []

    $scope.save = (newPost, parent, authorProfile) ->
        if parent
            newPost["parent"] = parent.resource_uri

        Post.post(newPost).then((postResult) ->
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

                DataSharing.sharedObject = {'newAnswer' : postResult}
            else
                DataSharing.sharedObject = {'newThread' : postResult}
            return false #for hide form
        )
)
module.controller("PostCtrl", ($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) ->

    $scope.initFromID = (questionID) ->
        Post.one(questionID).get().then((postResult) ->
            $scope.post =  postResult
            $scope.getAuthor($scope.post.id)
            $scope.getContributors($scope.post.id)
            if $scope.post.answers_count > 0
                $scope.getAnswers($scope.post.id)
        )

    $scope.initFromSlug =  ->
        Post.one().get({'slug' : $stateParams.slug}).then((postResult) ->
            $scope.post =  postResult.objects[0]
            $scope.getAuthor($scope.post.id)
            $scope.getAnswers($scope.post.id)
            $scope.getSimilars($scope.post.id)
            DataSharing.sharedObject = {'post' : $scope.post}
        )

    $scope.$watch(
        ()->
            return DataSharing.sharedObject
        ,(newVal, oldVal) ->
            if DataSharing.sharedObject.hasOwnProperty('newAnswer')
                $scope.getAnswers($scope.post.id)
                delete DataSharing.sharedObject["newAnswer"]
    )


    $scope.getAuthor = (questionID) ->
        ObjectProfileLink.one().customGET('post/'+questionID, {level:30}).then((objectProfileLinkResults) ->
            $scope.author = objectProfileLinkResults.objects[0].profile
        )

    $scope.getContributors = (questionID) ->
        $scope.contributors = []
        ObjectProfileLink.one().customGET('post/'+questionID, {level:31}).then((objectProfileLinkResults) ->
            angular.forEach(objectProfileLinkResults.objects, (objectProfileLink) ->
                $scope.contributors.push(objectProfileLink.profile)
            )
        )

    $scope.getAnswers = (questionID) ->
        if $scope.post.parent
            $scope.subanswers = Post.one().customGETLIST(questionID + '/answers').$object
        else
            $scope.answers = Post.one().customGETLIST(questionID + '/answers').$object


    $scope.getSimilars = (questionID) ->
        $scope.similars = []
        TaggedItem.one().customGET("post/"+questionID+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'post'
                    Post.one(similar.id).get().then((postResult)->
                        $scope.similars.push(postResult)
                    )

            )
        )
)
