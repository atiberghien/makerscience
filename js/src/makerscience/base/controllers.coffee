module = angular.module("makerscience.base.controllers", ['makerscience.base.services', 'makerscience.profile.controllers',
                                                          'makerscience.catalog.controllers.project', 'makerscience.catalog.controllers.resource',
                                                          'commons.accounts.controllers', 'commons.graffiti.services'])

module.controller("MakerScienceAbstractListCtrl", ($scope, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """

    $scope.currentPage = 1
    $scope.params = {}

    $scope.getParams = ()->
        $scope.params['limit'] = $scope.limit
        if FilterService.filterParams.query
            $scope.params['q'] = FilterService.filterParams.query
        if FilterService.filterParams.tags
            $scope.params['facet'] = FilterService.filterParams.tags

    $scope.pageChanged = (newPage) ->
        $scope.params["offset"] = (newPage - 1) * $scope.limit
        $scope.refreshListGeneric()

    $scope.refreshListGeneric = ()->
        $scope.getParams()
        $scope.refreshList() #Must be defined in the subclass

    $scope.initMakerScienceAbstractListCtrl = () ->
        FilterService.filterParams.query = ''
        FilterService.filterParams.tags = []
        # $scope.refreshListGeneric()

        for param of FilterService.filterParams
            $scope.$watch(
                ()->
                    return FilterService.filterParams[param]
                ,(newVal, oldVal) ->
                    if newVal != oldVal
                        $scope.refreshListGeneric()
            )
)

module.controller('HomepageCtrl', ($scope, $filter, $controller, MakerScienceProjectLight, MakerScienceResourceLight, MakerScienceProfileLight, MakerSciencePostLight) ->
    angular.extend(this, $controller('PostCtrl', {$scope: $scope}))

    MakerScienceProjectLight.one().customGETLIST('search', {ordering: '-updated_on', limit : 3}).then((makerScienceProjectResults) ->
        $scope.projects =  makerScienceProjectResults
    )
    MakerScienceResourceLight.one().customGETLIST('search', {ordering: '-updated_on', limit : 3}).then((makerScienceResourceResults) ->
        $scope.resources =  makerScienceResourceResults
    )
    MakerScienceProjectLight.one().customGETLIST('search', {featured: true, ordering: '-updated_on', limit : 2}).then((makerScienceProjectResults) ->
        $scope.featuredProjects =  makerScienceProjectResults
    )
    MakerScienceResourceLight.one().customGETLIST('search', {featured: true, ordering: '-updated_on', limit : 2}).then((makerScienceResourceResults) ->
        $scope.featuredResources =  makerScienceResourceResults
    )

    MakerScienceProfileLight.one().customGETLIST('search', {ordering: '-date_joined', limit : 3}).then((makerScienceProfileResults) ->
        $scope.profiles =  makerScienceProfileResults
    )
    MakerSciencePostLight.one().customGETLIST('search', {ordering: '-created_on', limit : 5}).then((makerSciencePostResults) ->
        $scope.threads =  makerSciencePostResults
        angular.forEach($scope.threads, (thread) ->
            $scope.getPostAuthor(thread.parent_id).then((author) ->
                thread.author = author
            )
            $scope.getContributors(thread.parent_id).then((contributors) ->
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

            return null
)


module.controller("MakerScienceSearchCtrl", ($scope, $controller, $parse, $stateParams, Tag, TaggedItem, ObjectProfileLink,
                                            MakerScienceProjectLight, MakerScienceResourceLight, MakerScienceProfileLight, MakerSciencePostLight) ->

    $scope.collapseAdvancedSearch = true

    $scope.runSearch = (params) ->
        $scope.associatedTags = []

        findRelatedTag = (taggedItemResults) ->
            angular.forEach(taggedItemResults.objects, (taggedItem) ->
                if $scope.associatedTags.indexOf(taggedItem.tag.slug) == -1
                    $scope.associatedTags.push(taggedItem.tag.slug)
            )

        MakerScienceProfileLight.one().customGETLIST('search', params).then((makerScienceProfileResults) ->
            angular.forEach(makerScienceProfileResults, (profile) ->
                TaggedItem.one().customGET("makerscienceprofile/" + profile.id).then(findRelatedTag)
            )
            $scope.profiles = makerScienceProfileResults
        )
        MakerScienceProjectLight.one().customGETLIST('search', params).then((makerScienceProjectResults) ->
            angular.forEach(makerScienceProjectResults, (project) ->
                TaggedItem.one().customGET("makerscienceproject/" + project.id).then(findRelatedTag)
            )
            $scope.projects = makerScienceProjectResults
        )
        MakerScienceResourceLight.one().customGETLIST('search', params).then((makerScienceResourceResults) ->
            angular.forEach(makerScienceResourceResults, (resource) ->
                TaggedItem.one().customGET("makerscienceresource/" + resource.id).then(findRelatedTag)
            )
            $scope.resources = makerScienceResourceResults
        )
        MakerSciencePostLight.one().customGETLIST('search', params).then((makerSciencePostResults) ->
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
                        MakerScienceProfileLight.one().get({'parent__id' : genericProfileId}).then((makerScienceProfileResults) ->
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

    $scope.search = {
        advanced : true
        searchIn : 'all'
        allWords : []
        exactExpressions : []
    }

    $scope.runAdvancedSearch = (search) ->
        $scope.runSearch (search)
        $scope.search = {
            advanced : true
            searchIn : 'all'
            allWords : ""
            exactExpressions : ""
        }

    $scope.runAutoCompleteSearch = (query, lenght) ->
        if query.length >= lenght
            params = {
                limit : 2
                q : query
            }
            $scope.runSearch (params)

)


module.controller("FilterCtrl", ($scope, $stateParams, Tag, FilterService) ->

    $scope.tags_filter = []
    $scope.query_filter = ''

    $scope.refreshFilter = ()->
        """
        Update FilterService data
        """
        tags_list = []
        for tag in $scope.tags_filter
            tags_list.push(tag.text)
        FilterService.filterParams.tags = tags_list
        FilterService.filterParams.query = $scope.query_filter

    $scope.addToTagsFilter = (aTag)->
        simpleTag =
            text : aTag.name
        if $scope.tags_filter.indexOf(simpleTag) == -1
            $scope.tags_filter.push(simpleTag)
        $scope.refreshFilter()
)

module.controller("NotificationCtrl", ($scope, $controller, $timeout, $interval, $filter, ObjectProfileLink, Notification) ->

    $scope.updateNotifications = () ->
        if $scope.currentMakerScienceProfile != null && $scope.currentMakerScienceProfile != undefined
            Notification.getList({recipient_id : $scope.currentMakerScienceProfile.parent.user.id}).then((notificationResults)->
                $scope.notifications = notificationResults
                $scope.lastNotifications = $filter('limitTo')(notificationResults, 5)
                $scope.computeUnreadNotificationCounter()

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

module.controller('ReportAbuseFormInstanceCtrl' , ($scope, $modalInstance, $timeout, User, vcRecaptchaService, currentLocation) ->
    $scope.success = false

    $scope.setResponse = (response) ->
        $scope.response = response

    $scope.setWidgetId = (widgetId) ->
        $scope.widgetId = widgetId

    $scope.cbExpiration = () ->
        $scope.response = null

    $scope.sendMessage = (message) ->
        if $scope.response
            message.recaptcha_response = $scope.response
            message.subject = 'Un abus a été signalé sur la page ' + currentLocation
            User.one().customPOST(message, 'report/abuse', {}).then((response) ->
                $scope.success = true
                $timeout($modalInstance.close, 3000)
            , (response) ->
                console.log("RECAPTCHA ERROR", response)
            )
)

module.controller("ReportAbuseCtrl", ($scope, $modal) ->

    $scope.showReportAbusePopup = (currentLocation) ->
        console.log(currentLocation)
        modalInstance = $modal.open(
            templateUrl: '/views/base/abuse.html'
            controller: 'ReportAbuseFormInstanceCtrl'
            resolve:
                currentLocation : () ->
                    return currentLocation
        )
)

module.controller('BasicModalInstanceCtrl', ($scope, $modalInstance, content) ->

    $scope.content = content

    $scope.ok = () ->
        $modalInstance.close()

    $scope.cancel = () ->
        $modalInstance.dismiss('cancel')

)
