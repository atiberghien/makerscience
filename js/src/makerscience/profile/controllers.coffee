module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'makerscience.base.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile, FilterService) ->
    $scope.limit = 10
    $scope.params = {}

    $scope.refreshList = ()->
        console.log("refreshing Resource list !")
        $scope.params['limit'] = $scope.limit
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags
        $scope.profiles = MakerScienceProfile.one().customGETLIST('search', $scope.params).$object

    $scope.init = (limit) ->
        if limit
            $scope.limit = limit
        $scope.refreshList()

    $scope.$watch(
            ()->
                return FilterService.filterParams.tags
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    $scope.refreshList()
        )
    $scope.$watch(
            ()->
                return FilterService.filterParams.query
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    $scope.refreshList()
        )

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
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'MakerScienceProfile' then MakerScienceProfile.one(resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profile) ->
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'facebook', profile.facebook)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'twitter', profile.twitter)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'linkedin', profile.linkedin)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'contact_email', profile.contact_email)
    )
)
