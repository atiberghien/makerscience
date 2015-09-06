module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'makerscience.base.services',
                                                             'commons.accounts.services', 'makerscience.base.controllers'])

module.controller("MakerScienceProfileListCtrl", ($scope, $controller, MakerScienceProfileLight, MakerScienceProfileTaggedItem) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.fetchRecentProfiles = () ->
        $scope.params['ordering'] = '-date_joined'
        $scope.refreshList()

    $scope.fetchTopProfiles = () ->
        $scope.params['ordering'] = '-activity_score'
        $scope.refreshList()

    $scope.fetchRandomProfiles = () ->
        $scope.params['ordering'] = ''
        $scope.refreshList().then(->
            nbElmt = $scope.profiles.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.profiles[nbElmt]
                $scope.profiles[nbElmt] = $scope.profiles[rand]
                $scope.profiles[rand] = tmp
        )

    $scope.refreshList = ()->
        MakerScienceProfileLight.one().customGETLIST('search', $scope.params).then((makerScienceProfileResults) ->
            meta = makerScienceProfileResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.profiles =  makerScienceProfileResults
        )

    $scope.availableInterestTags = []
    $scope.availableSkillTags = []

    MakerScienceProfileTaggedItem.getList({distinct : 'True'}).then((taggedItemResults) ->
        angular.forEach(taggedItemResults, (taggedItem) ->
            switch taggedItem.tag_type
                when 'sk' then $scope.availableSkillTags.push(taggedItem.tag)
                when 'in' then $scope.availableInterestTags.push(taggedItem.tag)
        )
    )
)

module.controller('AvatarUploaderInstanceCtrl' , ($scope, $modalInstance, @$http, FileUploader) ->
    uploader = $scope.uploader = new FileUploader(
        url: config.media_uri + $scope.currentMakerScienceProfile.resource_uri + '/avatar/upload'
        queueLimit: 2
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )

    uploader.filters.push(
        name: 'imageFilter',
        fn: (item , options) ->
            type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|'
            return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) != -1
    )

    uploader.onAfterAddingFile = (item) ->
        if uploader.queue.length > 1
            uploader.removeFromQueue(0)
        item.croppedImage = ''
        reader = new FileReader();
        reader.onload = (event) ->
            $scope.$apply(()->
                item.image = event.target.result
            )
        reader.readAsDataURL(item._file)

    uploader.onBeforeUploadItem = (item) ->
        blob = dataURItoBlob(item.croppedImage)
        item._file = blob

    uploader.onSuccessItem = (item, response, status, headers) ->
        $modalInstance.close(response.avatar)

    dataURItoBlob = (dataURI) ->
        binary = atob(dataURI.split(',')[1])
        mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
        array = []
        array.push(binary.charCodeAt(i)) for i in [0 .. binary.length]

        return new Blob([new Uint8Array(array)], {type: mimeString})
)

module.controller("MakerScienceProfileCtrl", ($scope, $rootScope, $controller, $stateParams,$state, $modal, MakerScienceProfile, MakerScienceProfileLight, MakerScienceProjectLight, MakerScienceResourceLight,
                                            MakerScienceProfileTaggedItem, TaggedItem, Post, MakerSciencePost, ObjectProfileLink, Place) ->

    angular.extend(this, $controller('MakerScienceObjectGetter', {$scope: $scope}))
    angular.extend(this, $controller('TaggedItemCtrl', {$scope: $scope}))

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->

        $scope.profile = makerscienceProfileResult

        $scope.editable = $scope.profile.can_edit

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

        MakerScienceProfile.one($scope.profile.slug).customGET('activities').then((activityResults)->
            $scope.activities = activityResults.objects.activities
        )

        #Current profile is a member of a project team
        ObjectProfileLink.getList({profile__id : $scope.profile.parent.id}).then((objectProfileLinkResults)->
            angular.forEach(objectProfileLinkResults, (objectProfileLink) ->
                console.log(objectProfileLink.content_type)
                if  objectProfileLink.content_type == 'makerscienceproject'
                    MakerScienceProjectLight.one().get({parent__id : objectProfileLink.object_id}).then((makerscienceProjectResults) ->
                        if makerscienceProjectResults.objects.length == 1
                            if objectProfileLink.level == 0
                                $scope.member_projects.push(makerscienceProjectResults.objects[0])
                            else if objectProfileLink.level == 2
                                $scope.fan_projects.push(makerscienceProjectResults.objects[0])
                    )
                else if  objectProfileLink.content_type == 'makerscienceresource'
                    MakerScienceResourceLight.one().get({parent__id : objectProfileLink.object_id}).then((makerscienceResourceResults) ->
                        if makerscienceResourceResults.objects.length == 1
                            if objectProfileLink.level == 10
                                $scope.member_resources.push(makerscienceResourceResults.objects[0])
                            else if objectProfileLink.level == 12
                                $scope.fan_resources.push(makerscienceResourceResults.objects[0])
                    )
                else if objectProfileLink.content_type == 'makerscienceprofile' && objectProfileLink.level == 40
                    MakerScienceProfileLight.one().get({id : objectProfileLink.object_id}).then((profileResults) ->
                        if profileResults.objects.length == 1
                            $scope.friends.push(profileResults.objects[0])
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

        TaggedItem.one().customGET("makerscienceprofile/"+$scope.profile.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceprofile'
                    $scope.similars.push(MakerScienceProfileLight.one(similar.id).get().$object)
            )
        )

        angular.forEach($scope.profile.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "in" then $scope.preparedInterestTags.push({text : taggedItem.tag.name, slug: taggedItem.tag.slug, taggedItemId : taggedItem.id})
                when "sk" then $scope.preparedSkillTags.push({text : taggedItem.tag.name, slug: taggedItem.tag.slug, taggedItemId : taggedItem.id})
        )

        $scope.showAvatarPopup = () ->
            modalInstance = $modal.open(
                templateUrl: '/views/profile/block/avatar_uploader.html'
                controller: 'AvatarUploaderInstanceCtrl'
            )
            modalInstance.result.then((avatar) ->
                $scope.profile.parent.avatar = avatar
            )

        $scope.addTagToProfile = (tag_type, tag) ->
            MakerScienceProfileTaggedItem.one().customPOST({tag : tag.text}, "makerscienceprofile/"+$scope.profile.id+"/"+tag_type, {}).then((taggedItemResult) ->
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 50,
                    detail : '',
                    isValidated:true
                , 'taggeditem/'+taggedItemResult.id)
                if tag_type == 'in'
                    ObjectProfileLink.one().customPOST(
                        profile_id: $scope.currentMakerScienceProfile.parent.id,
                        level: 51,
                        detail : '',
                        isValidated:true
                    , 'tag/'+taggedItemResult.tag.id)
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

    , (response) ->
        if response.status == 404
            MakerScienceProfile.one().get({parent__id : $stateParams.slug}).then((makerscienceProfileResults) ->
                if makerscienceProfileResults.objects.length == 1
                    $state.go('profile.detail', {slug : makerscienceProfileResults.objects[0].slug})
                else
                    $state.go('404')
            , () ->
                $state.go('profile.list')
            )
    )
)

module.controller("MakerScienceProfileDashboardCtrl", ($scope, $rootScope, $controller, $stateParams, $state, MakerScienceProfile, Notification, ObjectProfileLink) ->

    angular.extend(this, $controller('NotificationCtrl', {$scope: $scope}))

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->

        $scope.profile = makerscienceProfileResult

        if !$scope.authVars.isAuthenticated || $scope.currentMakerScienceProfile.id != $scope.profile.id
            $state.go('profile.detail', {slug : $stateParams.slug})

        # $scope.notifications = Notification.getList({recipient_id : $scope.profile.parent.user.id}).$object

        MakerScienceProfile.one($scope.profile.slug).customGET('contacts/activities').then((activityResults)->
            $scope.activities = activityResults.objects
        )


    , (response) ->
        if response.status == 404
            MakerScienceProfile.one().get({parent__id : $stateParams.slug}).then((makerscienceProfileResults) ->
                if makerscienceProfileResults.objects.length == 1
                    $state.go('profile.dashboard', {slug : makerscienceProfileResults.objects[0].slug})
                else
                    $state.go('404')
            )
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
