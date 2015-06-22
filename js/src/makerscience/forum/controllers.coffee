module = angular.module("makerscience.forum.controllers", ["commons.megafon.controllers",
                                                           'makerscience.base.services','makerscience.base.controllers'])



module.controller("MakerSciencePostListCtrl", ($scope, $controller, MakerSciencePost) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.threads = MakerSciencePost.one().customGETLIST('search', $scope.params).$object

)

module.controller("MakerSciencePostCreateCtrl", ($scope, $controller, MakerSciencePost) ->
    angular.extend(this, $controller('PostCreateCtrl', {$scope: $scope}))

    $scope.saveMakersciencePost = (newPost, parent, authorProfile) ->
        $scope.savePost(newPost, parent, authorProfile).then((newPostURI)->

            MakerSciencePost.post({parent : newPostURI, post_type : newPost.type}).then((newMakerSciencePostResult) ->
                return false
            )
        )
)
