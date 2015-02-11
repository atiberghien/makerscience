module = angular.module("makerscience.base.controllers", ['makerscience.catalog.controllers'])

module.controller('LoginModalCtrl', ($scope, $modal) ->
    $scope.$watch('authVars.loginrequired', (newValue, oldValue) ->
        if oldValue == false && newValue == true
            modalInstance = $modal.open({
                templateUrl: 'loginModalContent.html',
            })
    )
)

module.controller('HomepageFeaturedListCtrl', ($scope, MakerScienceProject, MakerScienceResource) ->
    $scope.projects = MakerScienceProject.getList({limit:2, feature:true}).$object
    $scope.resources = MakerScienceResource.getList({limit:2, feature:true}).$object
)
