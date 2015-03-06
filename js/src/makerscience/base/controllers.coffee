module = angular.module("makerscience.base.controllers", ['makerscience.catalog.controllers', 'makerscience.profile.controllers'])

module.controller('CurrentMakerScienceProfileCtrl', ($scope, $rootScope, MakerScienceProfile) ->
    $rootScope.$watch('authVars.user', (newValue, oldValue) ->
        if newValue != oldValue
            MakerScienceProfile.one().get({parent__user__id : $rootScope.authVars.user.id}).then((profileResult)->
                $rootScope.currentMakerScienceProfile = profileResult.objects[0]
            )
    )
)

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


module.controller("MakerScienceObjectGetter", ($scope, MakerScienceProject, MakerScienceResource, MakerScienceProfile) ->

    $scope.getObject = (objectTypeName, objectId) ->
        if objectTypeName == 'makerscienceproject'
            MakerScienceProject.one(objectId).get().then((makerScienceProjectResult) ->
                $scope.project = makerScienceProjectResult
            )
        if objectTypeName == 'makerscienceresource'
            MakerScienceResource.one(objectId).get().then((makerScienceResourceResult) ->
                $scope.resource = makerScienceResourceResult
            )
        if objectTypeName == 'makerscienceprofile'
            MakerScienceProfile.one(objectId).get().then((makerScienceProfileResult) ->
                $scope.profile = makerScienceProfileResult
            )
)
