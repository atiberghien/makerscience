module = angular.module("makerscience.base.controllers",
    ['makerscience.base.services', 'makerscience.catalog.controllers', 'makerscience.profile.controllers', 'commons.accounts.controllers',
    'commons.graffiti.services'])


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

module.controller("MakerScienceAbstractListCtrl", ($scope, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """

    $scope.getParams = ()->
        $scope.params['limit'] = $scope.limit
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags

    $scope.refreshListGeneric = ()->
        $scope.getParams()
        $scope.refreshList()

    $scope.init = (params) ->
        $scope.limit = 12
        $scope.params = {}

        if params
            if params.hasOwnProperty('limit')
                 $scope.limit = params["limit"]
            if params.hasOwnProperty('featured')
                $scope.params['featured'] = params["features"]
            $scope.params = params

        # Refresh FilterService params
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

module.controller('HomepageFeaturedListCtrl', ($scope, MakerScienceProject, MakerScienceResource) ->
    $scope.projects = MakerScienceProject.getList({limit:2, feature:true}).$object
    $scope.resources = MakerScienceResource.getList({limit:2, feature:true}).$object
)


module.controller("StaticContentCtrl", ($scope, StaticContent) ->
    $scope.static = StaticContent.one(1).get().$object
)


module.controller("MakerScienceObjectGetter", ($scope, $q, Tag, TaggedItem, MakerScienceProject, MakerScienceResource, MakerScienceProfile, MakerSciencePost) ->
    $scope.getObject = (objectTypeName, objectId) ->
            if objectTypeName == 'project'
                return MakerScienceProject.one().get({parent__id : objectId}).then((makerScienceProjectResults) ->
                    if makerScienceProjectResults.objects.length == 1
                        $scope.project = makerScienceProjectResults.objects[0]
                        return $scope.project
                    else
                        return MakerScienceResource.one().get({parent__id : objectId}).then((makerScienceResourceResults) ->
                            if makerScienceResourceResults.objects.length == 1
                                $scope.resource = makerScienceResourceResults.objects[0]
                                return $scope.resource
                        )
                )
            if objectTypeName == 'makerscienceproject'
                return MakerScienceProject.one(objectId).get().then((makerScienceProjectResult) ->
                    $scope.project = makerScienceProjectResult
                    return $scope.project
                )
            if objectTypeName == 'makerscienceresource'
                return MakerScienceResource.one(objectId).get().then((makerScienceResourceResult) ->
                    $scope.resource = makerScienceResourceResult
                    return $scope.resource
                )
            if objectTypeName == 'makerscienceprofile'
                return MakerScienceProfile.one().get({id : objectId}).then((profileResults) ->
                    if profileResults.objects.length == 1
                        $scope.profile = profileResults.objects[0]
                        return $scope.profile
                )
            if objectTypeName == 'post'
                return MakerSciencePost.one().get({parent__id: objectId}).then((makerSciencePostResults) ->
                    if makerSciencePostResults.objects.length == 1
                        $scope.post = makerSciencePostResults.objects[0]
                        return $scope.post
                )
            if objectTypeName == 'taggeditem'
                return TaggedItem.one(objectId).get().then((taggedItemResult) ->
                    $scope.taggeditem = taggedItemResult
                    return $scope.taggeditem
                )
            if objectTypeName == 'tag'
                return Tag.one(objectId).get().then((tagResult) ->
                    $scope.tag = tagResult
                    return $scope.tag
                )
            console.log("Unable to fetch", objectTypeName, objectId)
            return null


    $scope.getMakerscienceProfileFromGenericProfile = (genericProfileId) ->
        MakerScienceProfile.one().get({'parent__id' : genericProfileId}).then((makerScienceProfileResult) ->
            $scope.makerscienceProfile = makerScienceProfileResult.objects[0]
        )
)


module.controller("MakerScienceSearchCtrl", ($scope, $stateParams, MakerScienceProject, MakerScienceResource, MakerScienceProfile) ->

    $scope.searchResult = {}
    $scope.search_form =
        query : ''

    if $stateParams.query
        $scope.search_form.query =  $stateParams.query

    $scope.refreshSearch = ()->
        $scope.searchResult = {}
        query = $scope.search_form.query
        $scope.searchResult['members'] = MakerScienceProfile.one().customGETLIST('search', {q:query}).$object
        $scope.searchResult['projects'] = MakerScienceProject.one().customGETLIST('search', {q:query}).$object
        $scope.searchResult['resources'] = MakerScienceResource.one().customGETLIST('search', {q:query}).$object

    $scope.refreshSearch()
)


module.controller("FilterCtrl", ($scope, $stateParams, Tag, FilterService) ->

    console.log("Init Filter Ctrl , state param ? ", $stateParams)
    $scope.suggestedTags = []
    $scope.tags_filter = []
    $scope.query_filter = ''

    $scope.load = (objectType)->
        console.log("loading filter on ", objectType)
        $scope.objectType = objectType
        $scope.suggestedTags = Tag.getList({content_type:objectType}).$object

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
