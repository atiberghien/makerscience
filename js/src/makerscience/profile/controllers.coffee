module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services',
        'makerscience.base.services', 'commons.accounts.services', 'makerscience.base.controllers'])

module.controller("MakerScienceProfileListCtrl", ($scope, $controller, MakerScienceProfile) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.profiles = MakerScienceProfile.one().customGETLIST('search', $scope.params).$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, MakerScienceProfile, MakerScienceProject, MakerScienceResource, MakerScienceProfileTaggedItem, ObjectProfileLink, PostalAddress) ->

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        $scope.preparedInterestTags = []
        $scope.preparedSkillTags = []

        $scope.member_projects = []
        $scope.member_resources = []
        $scope.fan_projects = []
        $scope.fan_resources = []

        ObjectProfileLink.getList({content_type:'project', profile__id : $scope.profile.parent.id}).then((linkedProjectResults)->
            angular.forEach(linkedProjectResults, (linkedProject) ->
                MakerScienceProject.one().get({parent__id : linkedProject.object_id}).then((makerscienceProjectResults) ->
                    if makerscienceProjectResults.objects.length == 1
                        if linkedProject.level == 0
                            $scope.member_projects.push(makerscienceProjectResults.objects[0])
                        else if linkedProject.level == 2
                            $scope.fan_projects.push(makerscienceProjectResults.objects[0])
                    else
                        MakerScienceResource.one().get({parent__id : linkedProject.object_id}).then((makerscienceResourceResults) ->
                            if makerscienceResourceResults.objects.length == 1
                                if linkedProject.level == 0
                                    $scope.member_resources.push(makerscienceResourceResults.objects[0])
                                else if linkedProject.level == 2
                                    $scope.fan_resources.push(makerscienceResourceResults.objects[0])
                        )
                )
            )
        )

        angular.forEach($scope.profile.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "in" then $scope.preparedInterestTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "sk" then $scope.preparedSkillTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToProfile = (tag_type, tag) ->
            MakerScienceProfileTaggedItem.one().customPOST({tag : tag.text}, "makerscienceprofile/"+$scope.profile.id+"/"+tag_type, {})

        $scope.removeTagFromProfile = (tag) ->
            MakerScienceProfileTaggedItem.one(tag.taggedItemId).remove()

        $scope.updateMakerScienceProfile = (resourceName, resourceId, fieldName, data) ->
            # in case of MakerScienceProfile, resourceId must be the profile slug
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'MakerScienceProfile' then MakerScienceProfile.one(resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profileSlug, socials) ->
            MakerScienceProfile.one(profileSlug).patch(socials)
    )
)
