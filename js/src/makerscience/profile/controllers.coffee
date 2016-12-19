module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'makerscience.base.services', 'commons.tags.services',
                                                             'commons.accounts.services', 'makerscience.base.controllers'])

module.controller("MakerScienceProfileListCtrl", ($scope, $controller, MakerScienceProfileLight, MakerScienceProfileTaggedItem) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.params["limit"] = $scope.limit =  6

    $scope.refreshList = ()->
        MakerScienceProfileLight.one().customGETLIST('search', $scope.params).then((makerScienceProfileResults) ->
            meta = makerScienceProfileResults.metadata
            $scope.totalItems = meta.total_count
            $scope.limit = meta.limit
            $scope.profiles =  makerScienceProfileResults
        )

    # Must be called AFTER refreshList definition due to inheriance
    $scope.initMakerScienceAbstractListCtrl()

    $scope.fetchRecentProfiles = () ->
        $scope.$broadcast('clearFacetFilter')
        $scope.params['ordering'] = '-date_joined'
        $scope.refreshList()

    $scope.fetchTopProfiles = () ->
        $scope.$broadcast('clearFacetFilter')
        $scope.params['ordering'] = '-activity_score'
        $scope.refreshList()

    $scope.fetchRandomProfiles = () ->
        $scope.$broadcast('clearFacetFilter')
        $scope.params['ordering'] = ''
        $scope.refreshList().then(->
            nbElmt = $scope.profiles.length
            while nbElmt
                rand = Math.floor(Math.random() * nbElmt--)
                tmp = $scope.profiles[nbElmt]
                $scope.profiles[nbElmt] = $scope.profiles[rand]
                $scope.profiles[rand] = tmp
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

module.controller('BioInstanceCtrl', ($scope, $modalInstance, MakerScienceProfile, editable, profile) ->
    $scope.editable = editable
    $scope.profile = profile

    $scope.ok = () ->
        if editable
            MakerScienceProfile.one($scope.profile.slug).patch({bio : $scope.profile.bio})
        $modalInstance.close()

    $scope.cancel = () ->
        $modalInstance.dismiss('cancel')
)

module.controller('SocialsEditInstanceCtrl', ($scope, $modalInstance, MakerScienceProfile, socials, profile) ->
    $scope.profile = profile
    $scope.socials = socials

    $scope.ok = () ->
        angular.forEach($scope.socials, (value, key) ->
            if value
                if value.startsWith("http://") == false or value.startsWith("https://") != false
                    value = "http://" + value
                $scope.profile[key] = value
        )
        MakerScienceProfile.one($scope.profile.slug).patch($scope.socials).then(->
            $modalInstance.close()
        )

    $scope.cancel = () ->
        $modalInstance.dismiss('cancel')
)

module.controller("MakerScienceProfileCtrl", ($scope, $rootScope, $controller, $stateParams,$state, $modal, TaggedItemService,
                                            MakerScienceProfile, MakerScienceProfileLight,
                                            MakerScienceProjectLight, MakerScienceResourceLight,
                                            MakerSciencePost, MakerSciencePostLight,
                                            MakerScienceProfileTaggedItem, TaggedItem,Tag, Post, ObjectProfileLink, PostalAddress) ->

    angular.extend(this, $controller('MakerScienceObjectGetter', {$scope: $scope}))
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))

    $scope.openTagPopup = (preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) ->
      TaggedItemService.openTagPopup(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback)

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->

        $scope.profile = makerscienceProfileResult

        $scope.editable = $scope.profile.can_edit

        $rootScope.$broadcast('profile-loaded', $scope.profile)
        $rootScope.$emit('profile-loaded', $scope.profile)

        $scope.preparedInterestTags = []
        $scope.preparedSkillTags = []

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

        ## INFINITE SCROLL PROFILE ACTIVITIES
        $scope.infiniteScrollActivitiesLimit = 3
        $scope.infiniteScrollActivitiesTotalCount = null
        $scope.infiniteScrollActivitiesCall = 0
        $scope.infiniteScrollActivitiesCounter = 1

        $scope.addMoreActivities = () ->
            $scope.infiniteScrollActivitiesCall++
            if $scope.infiniteScrollActivitiesTotalCount && $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter > $scope.infiniteScrollActivitiesTotalCount
                return

            if $scope.infiniteScrollActivitiesCall == $scope.infiniteScrollActivitiesCounter
                MakerScienceProfile.one($scope.profile.slug).customGET('activities', {limit : $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter}).then((activityResults)->
                    $scope.infiniteScrollActivitiesTotalCount = activityResults.metadata.total_count
                    $scope.infiniteScrollActivities = activityResults.objects
                    $scope.infiniteScrollActivitiesCounter++
                )
            else
                $scope.infiniteScrollActivitiesCall--
        #################################

        $scope.addMoreActivities()

        #Current profile is a member of a project team

        MakerScienceProfile.one($stateParams.slug).customGET("makerscienceproject/0").then((results) ->
            $scope.member_projects = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("makerscienceproject/2").then((results) ->
            $scope.fan_projects = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("makerscienceresource/10").then((results) ->
            $scope.member_resources = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("makerscienceresource/12").then((results) ->
            $scope.fan_resources  = results
        )

        MakerScienceProfile.one($stateParams.slug).customGET("makerscienceprofile/40").then((results) ->
            $scope.friends  = results

            $scope.bigTotalItems = $scope.friends.length;
            $scope.bigCurrentPage = 1;
            $scope.itemsPerPage = 8
            $scope.numPages = Math.ceil($scope.bigTotalItems / $scope.itemsPerPage)

            $scope.paginationFriends = results.slice(($scope.bigCurrentPage-1) * $scope.itemsPerPage,
                                                     $scope.bigCurrentPage * $scope.itemsPerPage)

            $scope.pageChanged = (pageNum) ->
                $scope.bigCurrentPage = pageNum
                $scope.paginationFriends = results.slice(($scope.bigCurrentPage-1) * $scope.itemsPerPage,
                                                         $scope.bigCurrentPage * $scope.itemsPerPage)

            $scope.maxSize = 5;
        )



        MakerScienceProfile.one($stateParams.slug).customGET("post/30", {lookup_field : 'parent__id'}).then((results) ->
            $scope.authored_post  = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("post/31", {lookup_field : 'parent__id'}).then((results) ->
            $scope.contributed_post  = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("post/32", {lookup_field : 'parent__id'}).then((results) ->
            $scope.followed_post  = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("post/33", {lookup_field : 'parent__id'}).then((results) ->
            $scope.liked_post  = results
        )
        MakerScienceProfile.one($stateParams.slug).customGET("taggeditem/50").then((results) ->
            angular.forEach(results, (taggedItemResult) ->
                slug = taggedItemResult.tag.slug
                if $scope.favoriteTags.hasOwnProperty(slug)
                    $scope.favoriteTags[slug]++
                else
                    $scope.favoriteTags[slug] = 1
            )
        )
        MakerScienceProfile.one($stateParams.slug).customGET("tag/51").then((results) ->
            $scope.followedTags = results
        )

        TaggedItem.one().customGET("makerscienceprofile/"+$scope.profile.id+"/similars").then((similarResults) ->
            angular.forEach(similarResults, (similar) ->
                if similar.type == 'makerscienceprofile'
                    MakerScienceProfileLight.one().get({id: similar.id}).then((makersciencePostResults)->
                        $scope.similars.push(makersciencePostResults.objects[0])
                    )
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
                $scope.currentMakerScienceProfile.parent.avatar = avatar
            )

        $scope.openBioPopup = (editable) ->
            modalInstance = $modal.open(
                templateUrl: '/views/profile/block/bioModal.html'
                controller: 'BioInstanceCtrl'
                resolve:
                    editable : () ->
                        return editable
                    profile : () ->
                        return $scope.profile

            )

        $scope.openSocialsEditPopup = () ->
            modalInstance = $modal.open(
                templateUrl: 'views/profile/block/socialsEditPopup.html'
                controller: 'SocialsEditInstanceCtrl'
                resolve:
                    profile : () ->
                        return $scope.profile
                    socials : () ->
                        return $scope.socials

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
                tag.taggedItemId = taggedItemResult.id
            )

        $scope.removeTagFromProfile = (tag) ->
            MakerScienceProfileTaggedItem.one(tag.taggedItemId).remove()

        $scope.updateMakerScienceProfile = (resourceName, resourceId, fieldName, data) ->
            # in case of MakerScienceProfile, resourceId must be the profile slug
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'MakerScienceProfile' then MakerScienceProfile.one(resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

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

module.controller("MakerScienceResetPasswordCtrl", ($scope, $state, $stateParams, $timeout, MakerScienceProfile) ->


    $scope.passwordResetFail = false
    $scope.passwordResetSuccess = false

    $scope.notMatchingEmailError = false
    $scope.passwordReset = ''
    $scope.passwordReset2 = ''


    if $stateParams.hasOwnProperty('hash') && $stateParams.hasOwnProperty('email')
        $scope.email = $stateParams.email

        $scope.finalizeResetPassword = () ->
            $scope.passwordResetFail = false
            $scope.passwordResetSuccess = false

            if $scope.passwordReset != null && $scope.passwordReset != $scope.passwordReset2
                $scope.passwordResetFail = true
                return
            else
                MakerScienceProfile.one().customGET('reset/password', {email: $scope.email, hash : $stateParams.hash, password: $scope.passwordReset}).then((result) ->
                    if result.success
                        $scope.passwordResetSuccess = true
                        $timeout(()->
                            $state.go('home')
                        , 5000)
                    else
                        $scope.notMatchingEmailError = true
                )


    $scope.resetPassword = (email) ->
        $scope.unknownProfileError = false
        $scope.passwordResetEmailSent = false
        MakerScienceProfile.one().customGET('reset/password', {email: email}).then((result) ->
            if result.success
                $scope.passwordResetEmailSent = true
            else
                $scope.unknownProfileError = true
        )

)


module.controller("MakerScienceProfileDashboardCtrl", ($scope, $rootScope, $controller, $stateParams, $state, MakerScienceProfile, User,Notification,ObjectProfileLink) ->

    MakerScienceProfile.one($stateParams.slug).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        if !$scope.authVars.isAuthenticated || $scope.currentMakerScienceProfile == undefined || $scope.currentMakerScienceProfile.id != $scope.profile.id
            $state.go('profile.detail', {slug : $stateParams.slug})

        $scope.user = {
            first_name : $scope.profile.parent.user.first_name
            last_name : $scope.profile.parent.user.last_name
            email : $scope.profile.parent.user.email
            notifFreq : $scope.profile.notif_subcription_freq
            authorizedContact  : $scope.profile.authorized_contact
            passwordReset : ''
            passwordReset2 : ''
        }
        $scope.passwordError = false
        $scope.passwordResetSuccess = false

        ## INFINITE SCROLL NOTIFICATIONS
        $scope.infiniteScrollNotificationsLimit = 6
        $scope.infiniteScrollNotificationsTotalCount = null
        $scope.infiniteScrollNotificationsCall = 0
        $scope.infiniteScrollNotificationsCounter = 1

        $scope.addMoreNotifications = () ->
            $scope.infiniteScrollNotificationsCall++
            if $scope.infiniteScrollNotificationsTotalCount && $scope.infiniteScrollNotificationsLimit * $scope.infiniteScrollNotificationsCounter > $scope.infiniteScrollNotificationsTotalCount
                return

            if $scope.infiniteScrollNotificationsCall == $scope.infiniteScrollNotificationsCounter
                Notification.getList({recipient_id : $scope.profile.parent.user.id, limit : $scope.infiniteScrollNotificationsLimit * $scope.infiniteScrollNotificationsCounter}).then((notificationResults)->
                    $scope.infiniteScrollNotificationsTotalCount = notificationResults.metadata.total_count
                    $scope.infiniteScrollNotifications = notificationResults
                    $scope.infiniteScrollNotificationsCounter++
                )
            else
                $scope.infiniteScrollNotificationsCall--
        #################################

        ## INFINITE SCROLL FRIEND ACTIVITIES
        $scope.infiniteScrollActivitiesLimit = 6
        $scope.infiniteScrollActivitiesTotalCount = null
        $scope.infiniteScrollActivitiesCall = 0
        $scope.infiniteScrollActivitiesCounter = 1

        $scope.addMoreActivities = () ->
            $scope.infiniteScrollActivitiesCall++
            if $scope.infiniteScrollActivitiesTotalCount && $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter > $scope.infiniteScrollActivitiesTotalCount
                return

            if $scope.infiniteScrollActivitiesCall == $scope.infiniteScrollActivitiesCounter
                MakerScienceProfile.one($scope.profile.slug).customGET('contacts/activities', {limit : $scope.infiniteScrollActivitiesLimit * $scope.infiniteScrollActivitiesCounter}).then((activityResults)->
                    $scope.infiniteScrollActivitiesTotalCount = activityResults.metadata.total_count
                    $scope.infiniteScrollActivities = activityResults.objects
                    $scope.infiniteScrollActivitiesCounter++
                )
            else
                $scope.infiniteScrollActivitiesCall--
        #################################

        $scope.addMoreNotifications()
        $scope.addMoreActivities()

        $scope.deleteProfile = () ->
            MakerScienceProfile.one($scope.profile.slug).remove()
            $rootScope.loginService.logout()
            $state.go("home", {})

        $scope.updateMakerScienceUserInfo = () ->
            angular.forEach($scope.user, (value, key) ->
                data = {}
                data[key] = value
                User.one($scope.profile.parent.user.username).patch(data)
            )
            $scope.profile.full_name = $scope.user.first_name + " " + $scope.user.last_name

        $scope.updateNotifFrequency = (frequency)->
            MakerScienceProfile.one($scope.profile.slug).patch({notif_subcription_freq : frequency})
            $scope.user.notifFreq = frequency

        $scope.updateAuthorizedContact = (authorizedContact)->
            MakerScienceProfile.one($scope.profile.slug).patch({authorized_contact : authorizedContact})
            $scope.user.authorizedContact = authorizedContact

        $scope.changeMakerScienceProfilePassword = () ->
            $scope.passwordResetFail = false
            $scope.passwordResetSuccess = false

            if $scope.user.passwordReset != null && $scope.user.passwordReset != $scope.user.passwordReset2
                $scope.passwordResetFail = true
                return
            else
                MakerScienceProfile.one($scope.profile.slug).customPOST({password : $scope.user.passwordReset}, 'change/password', {}).then((result)->
                    $scope.passwordResetsuccess = true
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

module.controller("FriendshipCtrl", ($scope, $rootScope, $modal, ObjectProfileLink, MakerScienceProfile) ->

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

    $scope.checkFriend = (makerscienceProfileID) ->
        if $scope.currentMakerScienceProfile && makerscienceProfileID
            ObjectProfileLink.one().customGET('makerscienceprofile/'+makerscienceProfileID, {profile__id: $scope.currentMakerScienceProfile.parent.id, level:40}).then((objectProfileLinkResults) ->
                if objectProfileLinkResults.objects.length == 1
                    # console.log("YES : current profile #", $scope.currentMakerScienceProfile.parent.id, 'is following mks profile #', makerscienceProfileID)
                    $scope.isFriend = true
                    return objectProfileLinkResults.objects[0]
            )

    $scope.checkFollowing = (profileID) ->
        # console.log("checkFollowing", $scope.currentMakerScienceProfile , profileID)
        if $scope.currentMakerScienceProfile && profileID
            MakerScienceProfile.one().get({parent__id : profileID}).then((makerscienceProfileResults) ->
                if makerscienceProfileResults.objects.length == 1
                    $scope.viewedMakerscienceProfile = makerscienceProfileResults.objects[0]
                    ObjectProfileLink.one().customGET('makerscienceprofile/'+$scope.currentMakerScienceProfile.id, {profile__id: profileID, level:40}).then((objectProfileLinkResults) ->
                        # console.log(profileID, 'makerscienceprofile/'+$scope.currentMakerScienceProfile.id)
                        if objectProfileLinkResults.objects.length == 1
                            # console.log("YES : current mks profile #", $scope.currentMakerScienceProfile.id, 'is followed by basic profile #', profileID)
                            $scope.isFollowed = true
                            return objectProfileLinkResults.objects[0]
                    )
            )

    $scope.showContactPopup = (profile) ->
        ## FIXME UGLY WORKAROUND
        if typeof(profile) == 'number'
            # mean that profile is the id of a basic profile resource
            # need to fetch the related MakerscienceProfile
            MakerScienceProfile.one().get({parent__id : profile}).then((makerscienceProfileResults) ->
                if makerscienceProfileResults.objects.length == 1
                    $modal.open(
                        templateUrl: '/views/profile/block/contact.html'
                        controller: 'ContactFormInstanceCtrl'
                        resolve:
                            profile : () ->
                                return makerscienceProfileResults.objects[0]
                    )
            )
        else
            $modal.open(
                templateUrl: '/views/profile/block/contact.html'
                controller: 'ContactFormInstanceCtrl'
                resolve:
                    profile : () ->
                        return profile
            )



    $rootScope.$on('profile-loaded', (event, profile) ->
        $scope.checkFriend(profile.id)
    )
)

module.controller('ContactFormInstanceCtrl' , ($scope, $modalInstance, $timeout, MakerScienceProfile, vcRecaptchaService, profile) ->
    $scope.success = false
    $scope.profile = profile

    $scope.setResponse = (response) ->
        $scope.response = response

    $scope.setWidgetId = (widgetId) ->
        $scope.widgetId = widgetId

    $scope.cbExpiration = () ->
        $scope.response = null

    $scope.sendMessage = (message) ->
        if $scope.response
            message.recaptcha_response = $scope.response
            MakerScienceProfile.one(profile.slug).customPOST(message, 'send/message', {}).then((response) ->
                $scope.success = true
                $timeout($modalInstance.close, 3000)
            , (response) ->
                console.log("RECAPTCHA ERROR", response)
            )
)
