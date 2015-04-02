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


module.controller('HomepageFeaturedListCtrl', ($scope, MakerScienceProject, MakerScienceResource) ->
    $scope.projects = MakerScienceProject.getList({limit:2, feature:true}).$object
    $scope.resources = MakerScienceResource.getList({limit:2, feature:true}).$object
)


module.controller("StaticContentCtrl", ($scope, StaticContent) ->
    $scope.static = StaticContent.one(1).get().$object
)


module.controller("MakerScienceObjectGetter", ($scope, MakerScienceProject, MakerScienceResource, MakerScienceProfile) ->

    $scope.getObject = (objectTypeName, objectId) ->
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
        $scope.searchResult['members'] = MakerScienceProfile.one().getList().$object
        $scope.searchResult['projects'] = MakerScienceProject.one().customGETLIST('search', {q:query}).$object
        $scope.searchResult['resources'] = MakerScienceResource.one().customGETLIST('search', {q:query}).$object 

    $scope.refreshSearch()
)


module.controller("FilterCtrl", ($scope, $stateParams, Tag, FilterService) ->
    
    console.log(" INit Filter Ctrl , state param ? ", $stateParams)
    $scope.objectType = 'project'
    $scope.suggestedTags = Tag.getList().$object
    $scope.tags_filter = []
    $scope.query_filter = ''

    $scope.load = (objectType)->
        console.log("loading filter on ", objectType)
        $scope.objectType = objectType


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

        # switch $scope.objectType
        #     when 'project'
        #         console.log("refreshing projects", $scope.projects)
        #         $scope.projects = MakerScienceProject.one().customGETLIST('search', {q:$scope.search_form.query, facet:tags_list}).$object
   

    $scope.addToTagsFilter = (aTag)->
        simpleTag = 
            text : aTag.name 
        if $scope.tags_filter.indexOf(simpleTag) == -1
            $scope.tags_filter.push(simpleTag)
        $scope.refreshFilter()        
)
