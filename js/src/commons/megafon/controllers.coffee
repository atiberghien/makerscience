module = angular.module("commons.megafon.controllers", ['commons.megafon.services'])

module.controller("QuestionListCtrl", ($scope, Post) ->
    Post.one().customGET('questions').then((questionResults) ->
        $scope.questions = questionResults.objects
    )
)

module.controller("PostCtrl", ($scope, $stateParams, Post) ->

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
)
