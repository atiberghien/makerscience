module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("QuestionListCtrl", ($scope, Post) ->

    $scope.init = (orderBy) ->
        Post.one().customGET('questions', orderBy).then((questionResults) ->
            $scope.questions = questionResults.objects
        )
)

module.controller("PostCtrl", ($scope, $stateParams, Post, TaggedItem) ->

    $scope.init = ->
        Post.one().get({'slug' : $stateParams.slug}).then((postResult) ->
            $scope.question =  postResult.objects[0]
            $scope.getContributors($scope.question.id)
            $scope.getAnswers($scope.question.id)
        )

    $scope.getContributors = (questionID) ->
        $scope.contributors = Post.one().customGETLIST(questionID + '/contributors').$object

    $scope.getAnswers = (postID) ->
        $scope.answers = Post.one().customGETLIST(postID + '/answers').$object

    $scope.save = (newPost, authorProfile) ->
        tags = newPost["tags"]
        delete newPost["tags"]
        newPost["author"] = authorProfile.resource_uri
        Post.post(newPost).then((postResult) ->
            angular.forEach(tags, (tag)->
                TaggedItem.one().customPOST({tag : tag.text}, "post/"+postResult.id, {})
            )
        )
)
