module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.init = (limit) ->
        params = {}
        if limit
            params['limit'] = limit
        $scope.profiles = MakerScienceProfile.getList(params).$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, MakerScienceProfile, MakerScienceProject, MakerScienceResource) ->

    MakerScienceProfile.one($stateParams.id).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        $scope.member_projects = []
        $scope.member_resources = []

        angular.forEach($scope.profile.teams, (team) ->
            MakerScienceProject.one().get({parent__id : getObjectIdFromURI(team.project)}).then((makerscienceProjectResults) ->
                if makerscienceProjectResults.objects.length == 1
                    $scope.member_projects.push(makerscienceProjectResults.objects[0])
                else
                    MakerScienceResource.one().get({parent__id : getObjectIdFromURI(team.project)}).then((makerscienceResourceResults) ->
                        if makerscienceResourceResults.objects.length == 1
                            $scope.member_resources.push(makerscienceResourceResults.objects[0])
                    )
            )
        )


    )
)
