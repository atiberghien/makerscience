module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services',
        'makerscience.base.services', 'commons.accounts.services', 'makerscience.base.controllers'])

module.controller("MakerScienceProfileListCtrl", ($scope, $controller, MakerScienceProfile) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.profiles = MakerScienceProfile.one().customGETLIST('search', $scope.params).$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, MakerScienceProfile, MakerScienceProject, MakerScienceResource,
                                            MakerScienceProfileTaggedItem, Post, MakerSciencePost, ObjectProfileLink, Place) ->

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        $scope.preparedInterestTags = []
        $scope.preparedSkillTags = []

        $scope.member_projects = []
        $scope.member_resources = []

        $scope.fan_projects = []
        $scope.fan_resources = []

        $scope.authored_post = []
        $scope.contributed_post = []
        $scope.liked_post = []
        $scope.followed_post = []

        ObjectProfileLink.getList({content_type:'project', profile__id : $scope.profile.parent.id}).then((linkedProjectResults)->
            angular.forEach(linkedProjectResults, (linkedProject) ->
                MakerScienceProject.one().get({parent__id : linkedProject.object_id}).then((makerscienceProjectResults) ->
                    if makerscienceProjectResults.objects.length == 1 #FIXME Why this test ??? in case of MKS project and commons project mismatch
                        if linkedProject.level == 0
                            $scope.member_projects.push(makerscienceProjectResults.objects[0])
                        else if linkedProject.level == 2
                            $scope.fan_projects.push(makerscienceProjectResults.objects[0])
                    else
                        MakerScienceResource.one().get({parent__id : linkedProject.object_id}).then((makerscienceResourceResults) ->
                            if makerscienceResourceResults.objects.length == 1#FIXME Why this test
                                if linkedProject.level == 0
                                    $scope.member_resources.push(makerscienceResourceResults.objects[0])
                                else if linkedProject.level == 2
                                    $scope.fan_resources.push(makerscienceResourceResults.objects[0])
                        )
                )
            )
        )

        ObjectProfileLink.getList({content_type:'post', profile__id : $scope.profile.parent.id}).then((linkedPostResults)->
            angular.forEach(linkedPostResults, (linkedPost) ->
                MakerSciencePost.one().get({parent__id : linkedPost.object_id}).then((makersciencePostResults) ->
                    if makersciencePostResults.objects.length == 1
                        post = makersciencePostResults.objects[0]
                        if linkedPost.level == 30 && $scope.authored_post.indexOf(post) == -1
                            $scope.authored_post.push(post)
                        else if linkedPost.level == 33 && $scope.liked_post.indexOf(post) == -1
                            $scope.liked_post.push(post)
                        else if linkedPost.level == 32 && $scope.followed_post.indexOf(post) == -1
                            $scope.followed_post.push(post)
                    else
                        #anwers and subanswers have no related MakerSciencePost object
                        if linkedPost.level == 31
                            Post.one(linkedPost.object_id).customGET("root").then((root) ->
                                MakerSciencePost.one().get({parent__id : root.id}).then((makersciencePostResults) ->
                                    post = makersciencePostResults.objects[0]
                                    if $scope.contributed_post.indexOf(post) == -1
                                        $scope.contributed_post.push(post)
                                )
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
                when 'Place' then Place.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profileSlug, socials) ->
            MakerScienceProfile.one(profileSlug).patch(socials)
    )
)
