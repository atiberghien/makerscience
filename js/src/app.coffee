angular.module('commons.catalog', ['commons.catalog.controllers', 'commons.catalog.services'])
angular.module('makerscience.catalog', ['makerscience.catalog.controllers'])
angular.module('makerscience', ['commons.catalog', 'makerscience.catalog', 'restangular', 'ui.bootstrap', 'ui.router', 'xeditable', 'textAngular', 'ngSanitize', 'ngTagsInput'])

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
                templateUrl: 'views/catalog/new_project.html'
        )
        .state('projectsheet',
                url: '/p/:slug',
                templateUrl: 'views/catalog/project_detail.html'
        )
        .state('resource-list',
                url: '/r/list',
                controller: 'ProjectListCtrl'
                templateUrl: 'views/catalog/resource_list.html'
        )
        .state('new-resource',
                url: '/r/new',
                templateUrl: 'views/catalog/new_resource.html'
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
.run((editableOptions, editableThemes) ->
    editableOptions.theme = 'bs3'
    editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary">Enregistrer</button>'
    editableThemes['bs3'].cancelTpl = '<button type="button" class="btn btn-default" ng-click="$form.$cancel()">Annuler</button>'
)

angular.module('xeditable').directive('editableTextAngular', ['editableDirectiveFactory', (editableDirectiveFactory) ->
    return editableDirectiveFactory(
            directiveName : 'editableTextAngular'
            inputTpl : '<div text-angular></div>'
    )]
)
