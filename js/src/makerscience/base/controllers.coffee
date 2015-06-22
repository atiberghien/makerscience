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
    $scope.limit = 12
    $scope.params = {}

    $scope.getParams = ()->
        $scope.params['limit'] = $scope.limit
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags

    $scope.refreshListGeneric = ()->
        $scope.getParams()
        $scope.refreshList()

    $scope.init = (params) ->
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


module.controller("MakerScienceObjectGetter", ($scope, $q, MakerScienceProject, MakerScienceResource, MakerScienceProfile, Post) ->
    $scope.getObject = (objectTypeName, objectId) ->
        deferred = $q.defer();
        promise = deferred.promise;
        promise.then(->
            if objectTypeName == 'makerscienceproject'
                MakerScienceProject.one(objectId).get().then((makerScienceProjectResult) ->
                    $scope.project = makerScienceProjectResult
                )
            if objectTypeName == 'makerscienceresource'
                MakerScienceResource.one(objectId).get().then((makerScienceResourceResult) ->
                    $scope.resource = makerScienceResourceResult
                )
            if objectTypeName == 'makerscienceprofile'
                MakerScienceProfile.one(objectId).get().then((makerScienceProfileResult) ->
                    $scope.profile = makerScienceProfileResult
                )
            # if objectTypeName == 'post'
            #     Post.one(objectId).get().then((postResult) ->
            #         $scope.post = postResult
            #     )
        )
        deferred.resolve();

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
