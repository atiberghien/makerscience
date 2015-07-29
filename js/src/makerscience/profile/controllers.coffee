module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'makerscience.base.services',
                                                             'commons.accounts.services', 'makerscience.base.controllers'])

module.controller("MakerScienceProfileListCtrl", ($scope, $controller, MakerScienceProfile) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        $scope.profiles = MakerScienceProfile.one().customGETLIST('search', $scope.params).$object
)


module.controller("MakerScienceProfileCtrl", ($scope, $rootScope, $controller, $stateParams,$state, MakerScienceProfile, MakerScienceProject, MakerScienceResource,
                                            MakerScienceProfileTaggedItem, TaggedItem, Post, MakerSciencePost, ObjectProfileLink, Place) ->

    angular.extend(this, $controller('MakerScienceObjectGetter', {$scope: $scope}))

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        $rootScope.$broadcast('profile-loaded', $scope.profile)
        $rootScope.$emit('profile-loaded', $scope.profile)

        $scope.profileToUpdate = angular.copy($scope.profile)

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

        $scope.friends = []

        $scope.socials =
            facebook : $scope.profile.facebook
            linkedin : $scope.profile.linkedin
            twitter : $scope.profile.twitter
            contact_email : $scope.profile.contact_email
            website : $scope.profile.website

        $scope.similars = []

        $scope.favoriteTags = {}
        $scope.followedTags = []

        ObjectProfileLink.getList({profile__id : $scope.profile.parent.id}).then((objectProfileLinkResults) ->
            $scope.activities = objectProfileLinkResults
            angular.forEach($scope.activities, (activity) ->
                $scope.getObject(activity.content_type, activity.object_id).then((obj) ->
                    if activity.content_type == 'taggeditem'
                        if obj.tag.slug of $scope.favoriteTags
                            $scope.favoriteTags[obj.tag.slug]++
                        else
                            $scope.favoriteTags[obj.tag.slug] = 1
                    else if activity.content_type == 'tag'
                        $scope.followedTags.push(obj)
                    else
                        activity.content_object = obj
                )
            )
        )

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
                                if linkedProject.level == 10
                                    $scope.member_resources.push(makerscienceResourceResults.objects[0])
                                else if linkedProject.level == 12
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

        ObjectProfileLink.getList({content_type:'makerscienceprofile', profile__id : $scope.profile.parent.id, level : 40}).then((linkedFriendResults)->
            angular.forEach(linkedFriendResults, (linkedFriend) ->
                MakerScienceProfile.one().get({id : linkedFriend.object_id}).then((profileResults) ->
                    console.log(profileResults)
                    if profileResults.objects.length == 1
                        $scope.friends.push(profileResults.objects[0])
                )
            )
        )

        TaggedItem.one().customGET("makerscienceprofile/"+$scope.profile.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceprofile'
                    $scope.similars.push(MakerScienceProfile.one(similar.id).get().$object)
            )
        )

        angular.forEach($scope.profile.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "in" then $scope.preparedInterestTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "sk" then $scope.preparedSkillTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToProfile = (tag_type, tag) ->
            MakerScienceProfileTaggedItem.one().customPOST({tag : tag.text}, "makerscienceprofile/"+$scope.profile.id+"/"+tag_type, {}).then((taggedItemResult) ->
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 50,
                    detail : '',
                    isValidated:true
                , 'taggeditem/'+taggedItemResult.id)
            )

        $scope.removeTagFromProfile = (tag) ->
            MakerScienceProfileTaggedItem.one(tag.taggedItemId).remove()

        $scope.updateMakerScienceProfile = (resourceName, resourceId, fieldName, data) ->
            # in case of MakerScienceProfile, resourceId must be the profile slug
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'MakerScienceProfile' then MakerScienceProfile.one(resourceId).patch(putData)
                when 'Place' then Place.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profileSlug) ->
            angular.forEach($scope.socials, (value, key) ->
                if value != null || value != ""
                    $scope.profile[key] = value
            )
            MakerScienceProfile.one(profileSlug).patch($scope.socials)

        $scope.fullUpdateMakerScienceProfile = (makerscienceProfile) ->
            $scope.updateMakerScienceProfile('MakerScienceProfile', makerscienceProfile.slug , 'parent.user.last_name', makerscienceProfile.parent.user.last_name)
            $scope.updateMakerScienceProfile('MakerScienceProfile', makerscienceProfile.slug , 'parent.user.first_name', makerscienceProfile.parent.user.first_name)
            $scope.updateMakerScienceProfile('MakerScienceProfile', makerscienceProfile.slug , 'parent.user.email', makerscienceProfile.parent.user.email)

        $scope.deleteProfile = (makerscienceProfileSlug) ->
            MakerScienceProfile.one(makerscienceProfileSlug).remove()
            $rootScope.loginService.logout()
            $state.go("home", {})
    )
)

module.controller("FriendshipCtrl", ($scope, $rootScope, ObjectProfileLink) ->

    $scope.addFriend = (friendProfileID) ->
        ObjectProfileLink.one().customPOST(
            profile_id: $scope.currentMakerScienceProfile.parent.id,
            level: 40,
            detail : "Ami",
            isValidated:true
            , 'makerscienceprofile/'+friendProfileID)
        $scope.isFriend = true

    $scope.removeFriend = (friendProfileID) ->
        $scope.checkFriend(friendProfileID).then((currentLink) ->
            ObjectProfileLink.one(currentLink.id).remove()
            $scope.isFriend = false
        )

    $scope.checkFriend = (friendProfileID) ->
        if $scope.currentMakerScienceProfile
            ObjectProfileLink.one().customGET('makerscienceprofile/'+friendProfileID, {profile__id: $scope.currentMakerScienceProfile.parent.id, level:40}).then((objectProfileLinkResults) ->
                if objectProfileLinkResults.objects.length == 1
                    $scope.isFriend = true
                    return objectProfileLinkResults.objects[0]
            )

    $rootScope.$on('profile-loaded', (event, profile) ->
        $scope.checkFriend(profile.id)
    )
)
