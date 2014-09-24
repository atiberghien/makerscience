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
            
            $stateProvider.state('project-list',
                    url: '/project',
                    controller: 'ProjectListCtrl'
                    templateUrl: 'views/projectsheet/project_list.html'
            )

            .state('project-detail',
                    url: '/projectsheet/:id',
                    controller: 'ProjectDetailCtrl'
                    templateUrl: 'views/projectsheet/project_detail.html'
            )


    ])

    console.debug("running makerscience...")
    #angular.bootstrap(document, ['makerscience'])
