module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("ThreadListCtrl", ($scope, $q, Post, ObjectProfileLink) ->
    $scope.ordering = {'order_by' : '-updated_on'}

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

    $scope.savePost = (newPost, parent, authorProfile) ->
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

            $scope.$emit('post:new', postResult);

            return postResult.resource_uri
        )
)
module.controller("PostCtrl", ($scope, $stateParams, Post, TaggedItem, ObjectProfileLink, DataSharing) ->

    $scope.initFromID = (questionID) ->
        Post.one(questionID).get().then((postResult) ->
            $scope.basePost =  postResult

            ##Author
            ObjectProfileLink.one().customGET('post/'+questionID, {level:30}).then((objectProfileLinkResults) ->
                $scope.author = objectProfileLinkResults.objects[0].profile
            )

            ##contributors
            $scope.contributors = []
            contributorsIdx = []
            ObjectProfileLink.one().customGET('post/'+questionID, {level:31}).then((objectProfileLinkResults) ->
                angular.forEach(objectProfileLinkResults.objects, (objectProfileLink) ->
                    if contributorsIdx.indexOf(objectProfileLink.profile.id) == -1
                        contributorsIdx.push(objectProfileLink.profile.id)
                        $scope.contributors.push(objectProfileLink.profile)
                )
            )

            $scope.similars = []
            TaggedItem.one().customGET("post/"+questionID+"/similars").then((similarResults) ->
                angular.forEach(similarResults, (similar) ->
                    if similar.type == 'post'
                        Post.one(similar.id).get().then((postResult)->
                            $scope.similars.push(postResult)
                        )
                )
            )

            $scope.refreshAnswers = () ->
                $scope.answers = Post.one().customGETLIST($scope.basePost.id + '/answers').$object

            $scope.refreshAnswers()

            $scope.$on('post:new', $scope.refreshAnswers)
        )

)
