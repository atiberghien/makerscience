module = angular.module("makerscience.base.controllers", ['makerscience.catalog.controllers', 'makerscience.profile.controllers', 'commons.accounts.controllers'])

module.controller('CurrentMakerScienceProfileCtrl', ($scope, $rootScope, $modal, MakerScienceProfile) ->
    $rootScope.$watch('authVars.user', (newValue, oldValue) ->
        if newValue != oldValue
            MakerScienceProfile.one().get({parent__user__id : $rootScope.authVars.user.id}).then((profileResult)->
                $rootScope.currentMakerScienceProfile = profileResult.objects[0]
            )
    )

    $rootScope.openSignupPopup = ->
        modalInstance = $modal.open(
            templateUrl: 'views/base/signupModal.html',
            controller: 'SignupPopupCtrl'
    )
)

module.controller('SignupPopupCtrl', ($scope, $rootScope, $modalInstance, $state, User) ->
    $scope.register = ->
        $scope.user.email = $scope.user.username
        User.post($scope.user).then((userResult) ->
            $rootScope.authVars.username = $scope.user.username
            $rootScope.authVars.password = $scope.user.password
            $rootScope.loginService.submit()
            $rootScope.$watch('currentMakerScienceProfile', (newValue, oldValue) ->
                if newValue != oldValue
                    $modalInstance.close()
                    $state.go("profile.detail", {id : $rootScope.currentMakerScienceProfile.id})

            )
        )
)

module.directive('username', ($q, $timeout, User) ->
    require: 'ngModel'
    link: (scope, elm, attrs, ctrl) ->
        User.getList().then((userResults) ->
            usernames = userResults.map((user) ->
                return user.username
            )
            ctrl.$parsers.unshift((viewValue) ->
                if usernames.indexOf(viewValue) == -1
                    ctrl.$setValidity('username', true);
                else
                    ctrl.$setValidity('username', false);
            )
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
