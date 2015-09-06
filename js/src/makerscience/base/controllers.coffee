module = angular.module("makerscience.base.controllers", ['makerscience.base.services', 'makerscience.profile.controllers',
                                                          'makerscience.catalog.controllers.project', 'makerscience.catalog.controllers.resource',
                                                          'commons.accounts.controllers', 'commons.graffiti.services'])


module.directive('username', (User) ->
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

module.controller("MakerScienceAbstractListCtrl", ($scope, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """
    $scope.currentPage = 1
    $scope.params = {}

    $scope.getParams = ()->
        # $scope.params['limit'] = $scope.limit
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags

    $scope.pageChanged = (newPage) ->
        $scope.params["offset"] = (newPage - 1) * $scope.limit
        $scope.refreshList()

    $scope.refreshListGeneric = ()->
        $scope.getParams()
        $scope.refreshList() #Must be defined in the subclass

    $scope.init = (params) ->
        FilterService.filterParams.query = ''
        FilterService.filterParams.tags = []
        $scope.refreshListGeneric()

        for param of FilterService.filterParams
            $scope.$watch(
                ()->
                    return FilterService.filterParams[param]
                ,(newVal, oldVal) ->
                    if newVal != oldVal
                        $scope.refreshListGeneric()
            )
)

module.controller('HomepageCtrl', ($scope, $filter, MakerScienceProject, MakerScienceResource, MakerScienceProfile, MakerSciencePost) ->

    MakerScienceProject.one().customGETLIST('search', {ordering: '-updated_on', limit : 3}).then((makerScienceProjectResults) ->
        $scope.projects =  makerScienceProjectResults
    )
    MakerScienceResource.one().customGETLIST('search', {ordering: '-updated_on', limit : 3}).then((makerScienceResourceResults) ->
        $scope.resources =  makerScienceResourceResults
    )
    MakerScienceProfile.one().customGETLIST('search', {ordering: '-date_joined', limit : 3}).then((makerScienceProfileResults) ->
        $scope.profiles =  makerScienceProfileResults
    )
    MakerSciencePost.one().customGETLIST('search', {ordering: '-created_on', limit : 5}).then((makerSciencePostResults) ->
        $scope.threads =  makerSciencePostResults
        angular.forEach($scope.threads, (thread) ->
            $scope.getPostAuthor(thread.parent.id).then((author) ->
                thread.author = author
            )
            $scope.getContributors(thread.parent.id).then((contributors) ->
                thread.contributors = contributors
            )
        )
    )
)


module.controller("StaticContentCtrl", ($scope, StaticContent) ->
    $scope.static = StaticContent.one(1).get().$object
)


module.controller("MakerScienceObjectGetter", ($scope, $q, Vote, Tag, TaggedItem, MakerScienceProject, MakerScienceResource, MakerScienceProfile, MakerSciencePost) ->
    $scope.getObject = (objectTypeName, objectId) ->
            if objectTypeName == 'project'
                return MakerScienceProject.one().get({parent__id : objectId}).then((makerScienceProjectResults) ->
                    if makerScienceProjectResults.objects.length == 1
                        return makerScienceProjectResults.objects[0]
                    else
                        return MakerScienceResource.one().get({parent__id : objectId}).then((makerScienceResourceResults) ->
                            if makerScienceResourceResults.objects.length == 1
                                return makerScienceResourceResults.objects[0]
                        )
                )
            else if objectTypeName == 'makerscienceproject'
                return MakerScienceProject.one(objectId).get().then((makerScienceProjectResult) ->
                    return makerScienceProjectResult
                )
            else if objectTypeName == 'makerscienceresource'
                return MakerScienceResource.one(objectId).get().then((makerScienceResourceResult) ->
                    return makerScienceResourceResult
                )
            else if objectTypeName == 'makerscienceprofile'
                return MakerScienceProfile.one().get({id : objectId}).then((profileResults) ->
                    if profileResults.objects.length == 1
                        return profileResults.objects[0]
                )
            else if objectTypeName == 'profile'
                return MakerScienceProfile.one().get({parent__id : objectId}).then((profileResults) ->
                    if profileResults.objects.length == 1
                        return profileResults.objects[0]
                )
            else if objectTypeName == 'user'
                return MakerScienceProfile.one().get({parent__user__id : objectId}).then((profileResults) ->
                    if profileResults.objects.length == 1
                        return profileResults.objects[0]
                )
            else if objectTypeName == 'makersciencepost'
                return MakerSciencePost.one(objectId).get().then((makerSciencePostResult) ->
                    return makerSciencePostResult
                )
            else if objectTypeName == 'post'
                return MakerSciencePost.one().get({parent__id: objectId}).then((makerSciencePostResults) ->
                    if makerSciencePostResults.objects.length == 1
                        return makerSciencePostResults.objects[0]
                )
            else if objectTypeName == 'taggeditem'
                return TaggedItem.one(objectId).get().then((taggedItemResult) ->
                    return taggedItemResult
                )
            else if objectTypeName == 'tag'
                return Tag.one(objectId).get().then((tagResult) ->
                    return tagResult
                )
            else if objectTypeName == 'vote'
                return Vote.one(objectId).get()

            console.log("Unable to fetch", objectTypeName, objectId)
            return null
)


module.controller("MakerScienceSearchCtrl", ($scope, $controller, $parse, $stateParams, Tag, TaggedItem, ObjectProfileLink, MakerScienceProject, MakerScienceResource, MakerScienceProfile, MakerSciencePost) ->

    angular.extend(this, $controller('MakerScienceObjectGetter', {$scope: $scope}))

    $scope.runSearch = (params) ->
        $scope.associatedTags = []

        findRelatedTag = (taggedItemResults) ->
            angular.forEach(taggedItemResults.objects, (taggedItem) ->
                if $scope.associatedTags.indexOf(taggedItem.tag.slug) == -1
                    $scope.associatedTags.push(taggedItem.tag.slug)
            )

        MakerScienceProfile.one().customGETLIST('search', params).then((makerScienceProfileResults) ->
            angular.forEach(makerScienceProfileResults, (profile) ->
                TaggedItem.one().customGET("makerscienceprofile/" + profile.id).then(findRelatedTag)
            )
            $scope.profiles = makerScienceProfileResults
        )
        MakerScienceProject.one().customGETLIST('search', params).then((makerScienceProjectResults) ->
            angular.forEach(makerScienceProjectResults, (project) ->
                TaggedItem.one().customGET("makerscienceproject/" + project.id).then(findRelatedTag)
            )
            $scope.projects = makerScienceProjectResults
        )
        MakerScienceResource.one().customGETLIST('search', params).then((makerScienceResourceResults) ->
            angular.forEach(makerScienceResourceResults, (resource) ->
                TaggedItem.one().customGET("makerscienceresource/" + resource.id).then(findRelatedTag)
            )
            $scope.resources = makerScienceResourceResults
        )
        MakerSciencePost.one().customGETLIST('search', params).then((makerSciencePostResults) ->
            angular.forEach(makerSciencePostResults, (post) ->
                TaggedItem.one().customGET("makersciencepost/" + post.id).then(findRelatedTag)
            )
            $scope.discussions = makerSciencePostResults
        )

        TaggedItem.getList({tag__slug : params["facet"]}).then((taggedItemResults) ->
            $scope.taggerProfiles = []
            angular.forEach(taggedItemResults, (taggedItem) ->
                ObjectProfileLink.one().customGET('taggeditem/'+taggedItem.id).then((objectProfileLinkResults) ->
                    if objectProfileLinkResults.objects.length > 0
                        genericProfileId = objectProfileLinkResults.objects[0].profile.id
                        MakerScienceProfile.one().get({'parent__id' : genericProfileId}).then((makerScienceProfileResults) ->
                            if makerScienceProfileResults.objects.length > 0
                                tagger = makerScienceProfileResults.objects[0]
                                tagger.taggingDate = objectProfileLinkResults.objects[0].created_on
                                $scope.taggerProfiles.push(tagger)
                        )

                )
            )

        )


    if $stateParams.hasOwnProperty('q')
        $scope.query = $stateParams.q
        $scope.runSearch({q : $stateParams.q})
    if $stateParams.hasOwnProperty('slug')
        Tag.one().get({slug : $stateParams.slug}).then((tagResults) ->
            if tagResults.objects.length == 1
                $scope.tag = tagResults.objects[0]
                $scope.runSearch({facet : $stateParams.slug})

                $scope.followTag = (profileID) ->
                    ObjectProfileLink.one().customPOST(
                        profile_id: profileID,
                        level: 51,
                        detail : '',
                        isValidated:true
                    , 'tag/'+$scope.tag.id
                    )
        )


)


module.controller("FilterCtrl", ($scope, $stateParams, Tag, FilterService) ->

    console.log("Init Filter Ctrl , state param ? ", $stateParams)
    $scope.tags_filter = []
    $scope.query_filter = ''

    $scope.refreshFilter = ()->
        """
        Update FilterService data
        """
        console.log("refreshing filter (ctrler).. ", FilterService.filterParams)
        tags_list = []
        for tag in $scope.tags_filter
            tags_list.push(tag.text)
        FilterService.filterParams.tags = tags_list
        FilterService.filterParams.query = $scope.query_filter
        console.log("AFTER refreshing filter (ctrler).. ", FilterService.filterParams)

    $scope.addToTagsFilter = (aTag)->
        simpleTag =
            text : aTag.name
        if $scope.tags_filter.indexOf(simpleTag) == -1
            $scope.tags_filter.push(simpleTag)
        $scope.refreshFilter()
)

module.controller("NotificationCtrl", ($scope, $controller, $timeout, $interval, $filter, ObjectProfileLink, Notification) ->

    $scope.updateNotifications = () ->
        ObjectProfileLink.one().customGET('purge').then((result)->
            if $scope.currentMakerScienceProfile != null && $scope.currentMakerScienceProfile != undefined
                Notification.getList({recipient_id : $scope.currentMakerScienceProfile.parent.user.id}).then((notificationResults)->
                    $scope.notifications = $filter('orderBy')(notificationResults, 'timestamp', true)
                    $scope.lastNotifications = $filter('limitTo')($scope.notifications, 5)
                    $scope.computeUnreadNotificationCounter()

                )
        )

    $scope.computeUnreadNotificationCounter = () ->
        $scope.displayedUnreadNotifications = $filter('filter')($scope.lastNotifications, {unread:true})
        $scope.unreadNotificationCounter = $scope.displayedUnreadNotifications.length

    $scope.markDisplayedAsRead = () ->
        $timeout(()->
            angular.forEach($scope.displayedUnreadNotifications, $scope.markAsRead)
            $scope.computeUnreadNotificationCounter()
        , 2000)

    $scope.markAsRead = (notif) ->
        Notification.one(notif.id).patch({unread : false})
        notif.unread = false

    $scope.markAllAsRead = () ->
        angular.forEach($scope.notifications, $scope.markAsRead)

    $scope.$watch('currentMakerScienceProfile', (newValue, oldValue) ->
        if newValue != oldValue
            $scope.updateNotifications()
            $interval($scope.updateNotifications, 30000)
    )
)
