    angular.module('projectsheet', ['projectsheet.controllers', 'projectsheet.services', 'projectsheet.directives'])
    angular.module('makerscience', ['projectsheet', 'restangular', 'ui.bootstrap', 'ui.router'])
	
    # CORS
    .config(['$httpProvider', ($httpProvider) ->
            $httpProvider.defaults.useXDomain = true
            delete $httpProvider.defaults.headers.common['X-Requested-With']
    ])

    # Tastypie
    .config((RestangularProvider) ->
            RestangularProvider.setBaseUrl(config.rest_uri)
            RestangularProvider.setRequestSuffix('?format=json');
            # RestangularProvider.setDefaultHeaders({"Authorization": "ApiKey pipo:46fbf0f29a849563ebd36176e1352169fd486787"});
            # Tastypie patch
            RestangularProvider.setResponseExtractor((response, operation, what, url) ->
                    newResponse = null;

                    if operation is "getList"
                            newResponse = response.objects
                            newResponse.metadata = response.meta
                    else
                            newResponse = response

                    return newResponse
            )
    )

    # URI config
    .config(['$locationProvider', '$stateProvider', '$urlRouterProvider', ($locationProvider, $stateProvider, $urlRouterProvider) ->
            $locationProvider.html5Mode(config.useHtml5Mode)
            $urlRouterProvider.otherwise("/")
            
            $stateProvider.state('home',
                    url: '/',
                    controller: 'ProjectListCtrl'
                    templateUrl: 'views/catalog/project_list.html'
            )
            .state('project-list',
                    url: '/p/list',
                    controller: 'ProjectListCtrl'
                    templateUrl: 'views/catalog/project_list.html'
            )
            .state('new-projectsheet',
                    url: '/p/new',
                    controller: 'ProjectSheetCreateCtrl'
                    templateUrl: 'views/catalog/new_project.html'
            )
            .state('edit-projectsheet',
                    url: '/p/edit',
                    templateUrl: 'views/catalog/edit_project.html'
            )
            .state('projectsheet',
                    url: '/p/:slug',
                    controller: 'ProjectSheetCtrl'
                    templateUrl: 'views/catalog/project_detail.html'
            )
            .state('resourcesheet',
                    url: '/r/',
                    templateUrl: 'views/catalog/resource_detail.html'
            )
            .state('profile',
                    url: '/u',
                    templateUrl: 'views/profile/profile.html'
            )
            .state('profile-list',
                    url: '/u/list',
                    templateUrl: 'views/profile/profile_list.html'
            )

    ])

    console.debug("running makerscience...")
    #angular.bootstrap(document, ['makerscience'])
