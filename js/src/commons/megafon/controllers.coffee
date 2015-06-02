module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("QuestionListCtrl", ($scope, Post, DataSharing) ->

    $scope.init = (orderBy) ->
        Post.one().customGET('questions', orderBy).then((questionResults) ->
            $scope.questions = questionResults.objects
            DataSharing.sharedObject =  {discussions: $scope.questions}
        )
)

module.controller("PostCtrl", ($scope, $stateParams, Post, TaggedItem, DataSharing) ->

    $scope.questionTags = []

    $scope.init = ->
        $scope.getQuestion($stateParams.slug)

    $scope.getQuestion = (questionSlug) ->
        $scope.slug = questionSlug
        Post.one().get({'slug' : questionSlug}).then((postResult) ->
            $scope.question =  postResult.objects[0]
            $scope.getContributors($scope.question.id)
            $scope.getAnswers($scope.question.id)

        )

    $scope.getContributors = (questionID) ->
        $scope.contributors = Post.one().customGETLIST(questionID + '/contributors').$object

    $scope.getAnswers = (postID) ->
        $scope.answers = Post.one().customGETLIST(postID + '/answers').$object

    $scope.save = (newPost, parent, authorProfile) ->
        if parent
            newPost["parent"] = parent.resource_uri
        newPost["author"] = authorProfile.resource_uri
        Post.post(newPost).then((postResult) ->
            angular.forEach($scope.questionTags, (tag)->
                TaggedItem.one().customPOST({tag : tag.text}, "post/"+postResult.id, {})
            )
            console.log("DataSharing", DataSharing.sharedObject, DataSharing.sharedObject.hasOwnProperty("discussions"))
            if "discussions" in DataSharing.sharedObject
                DataSharing.sharedObject["discussions"].push(postResult)
            else if $scope.question
                $scope.init()

        )
)
