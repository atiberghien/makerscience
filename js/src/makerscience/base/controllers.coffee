module = angular.module("makerscience.base.controllers", 
    ['makerscience.catalog.controllers', 'makerscience.profile.controllers', 'commons.accounts.controllers',
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
        $scope.searchResult['resources'] = MakerScienceResource.one().getList().$object 

    $scope.refreshSearch()
)

module.controller("FilterCtrl", ($scope, $stateParams, MakerScienceProject, MakerScienceResource, MakerScienceProfile, Tag) ->
    $scope.suggestedTags = []
    $scope.searchTags = []
    console.log(" INit Filter Ctrl , state param ? ", $stateParams)
    $scope.objectType = 'project'
    $scope.search_form=
        query:''

    $scope.refreshSuggestedTags = ()->
        $scope.suggestedTags = Tag.getList().$object
        return true

    $scope.load = ()->
        $scope.refreshSuggestedTags()

    $scope.addToSearchTags = (aTag)->
        simpleTag = 
            text : aTag.name 
        if $scope.searchTags.indexOf(simpleTag) == -1
            $scope.searchTags.push(simpleTag)

    $scope.refreshFilter = ()->
        console.log("refreshing .. ", $scope.searchTags)
        tags_list = []
        for tag in $scope.searchTags
            tags_list.push(tag.text)
        switch $scope.objectType
            when 'project'
                console.log("refreshing projects", $scope.projects.list)
                $scope.projects.list = MakerScienceProject.one().customGETLIST('search', {q:$scope.search_form.query, facet:tags_list}).$object

)
