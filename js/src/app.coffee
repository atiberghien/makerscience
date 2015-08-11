angular.module('commons.catalog', ['commons.catalog.controllers', 'commons.catalog.services'])
angular.module('commons.accounts', ['commons.accounts.services', 'commons.accounts.controllers'])
angular.module('commons.ucomment', ['commons.ucomment.controllers', 'commons.ucomment.services'])
angular.module('commons.megafon', ['commons.megafon.controllers', 'commons.megafon.services'])
angular.module('commons.starlet', ['commons.starlet.controllers', 'commons.starlet.services'])
angular.module('makerscience.catalog', ['makerscience.catalog.controllers.project', 'makerscience.catalog.controllers.resource', 'makerscience.catalog.services', 'makerscience.catalog.directives'])
angular.module('makerscience.profile', ['makerscience.profile.controllers', 'makerscience.profile.services'])
angular.module('makerscience.base', ['makerscience.base.controllers', 'makerscience.base.services'])
angular.module('makerscience.map', ['makerscience.map.controllers'])
angular.module('makerscience.forum', ['makerscience.forum.controllers', 'makerscience.forum.services'])

angular.module('makerscience', ['commons.catalog', 'commons.accounts', 'commons.ucomment', 'makerscience.catalog', 'makerscience.profile', "makerscience.forum",
                                'makerscience.base','makerscience.map', 'commons.megafon', 'commons.starlet',
                                'restangular', 'ui.bootstrap', 'ui.router', 'xeditable', 'textAngular', 'angularFileUpload',
                                'ngSanitize', 'ngTagsInput', 'angularMoment', 'leaflet-directive', "angucomplete-alt", "videosharing-embed"
                                'geocoder-service', 'ncy-angular-breadcrumb', 'truncate', 'ui.unique', 'satellizer', 'ngCookies', '720kb.socialshare',
                                'sticky', 'mentio', 'ui.tinymce'])

# CORS
.config(['$httpProvider', ($httpProvider) ->
        $httpProvider.defaults.useXDomain = true
        delete $httpProvider.defaults.headers.common['X-Requested-With']
])

# Tastypie
.config((RestangularProvider) ->
        RestangularProvider.setBaseUrl(config.rest_uri)
        RestangularProvider.setRequestSuffix('?format=json');
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

.config(($authProvider, loginServiceProvider) ->
    $authProvider.httpInterceptor = false;

    $authProvider.facebook({
        url: config.loginBaseUrl + '/account/user/login/facebook',
        clientId: '724284684343376',
        scope: ['email', 'public_profile']
    })

    $authProvider.google({
        url: config.loginBaseUrl + '/account/user/login/google',
        clientId: '255067193649-5s7fan8nsch2cqft32fka9n36jcd37qg.apps.googleusercontent.com',
    })

    $authProvider.twitter({
        url : config.loginBaseUrl + '/account/user/login/twitter',
        clientId: 'RXz5fy5X4M1LewAeNliME2gbM',
        redirectUri : config.loginBaseUrl + '/account/user/login/twitter',
    })


)
# Unisson auth config
.config((loginServiceProvider) ->
    loginServiceProvider.setBaseUrl(config.loginBaseUrl)
)
# URI config
.config(['$locationProvider', '$stateProvider', '$urlRouterProvider', ($locationProvider, $stateProvider, $urlRouterProvider) ->

        $locationProvider.html5Mode(true).hashPrefix('!')
        $urlRouterProvider.otherwise("/")

        $stateProvider.state('home',
                url: '/',
                templateUrl: '/views/homepage.html',
                ncyBreadcrumb:
                    label: 'Accueil'
        )
        .state('project',
                url: '/p/'
                abstract: true,
                templateUrl : '/views/catalog/project.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('project.list',
                url: 'list',
                templateUrl: '/views/catalog/project.list.html',
                ncyBreadcrumb:
                    label: 'Projets'
        )
        .state('project.new',
                url: 'new',
                templateUrl: '/views/catalog/project.new.html',
                ncyBreadcrumb:
                    label: 'Nouveau projet'
                    parent : 'project.list'
        )
        .state('project.detail',
                url: ':slug',
                templateUrl: '/views/catalog/project.detail.html',
                controller : 'MakerScienceProjectSheetCtrl'
                ncyBreadcrumb:
                    label: '{{projectsheet.parent.title}}'
                    parent : 'project.list'
        )
        .state('resource',
                url : '/r/',
                abstract : true,
                templateUrl : '/views/catalog/resource.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('resource.list',
                url: 'list',
                templateUrl: '/views/catalog/resource.list.html'
                ncyBreadcrumb:
                    label: 'Expériences'
        )
        .state('resource.new',
                url: 'new',
                templateUrl: '/views/catalog/resource.new.html'
                ncyBreadcrumb:
                    label: 'Nouvelle expérience'
                    parent : 'resource.list'
        )
        .state('resource.detail',
                url: ':slug',
                templateUrl: '/views/catalog/resource.detail.html'
                controller: 'MakerScienceResourceSheetCtrl'
                ncyBreadcrumb:
                    label: '{{projectsheet.parent.title}}'
                    parent : 'resource.list'
        )
        .state('profile',
                url : '/u/',
                abstract : true,
                templateUrl : '/views/profile/profile.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('profile.list',
                url: 'list',
                templateUrl: '/views/profile/profile.list.html'
                ncyBreadcrumb:
                    label: 'Communauté'
        )
        .state('profile.detail',
                url: ':slug',
                templateUrl: '/views/profile/profile.detail.html'
                controller : 'MakerScienceProfileCtrl'
                ncyBreadcrumb:
                    label: '{{profile.parent.user.first_name}} {{profile.parent.user.last_name}}'
                    parent : 'profile.list'
        )
        .state('profile.dashboard',
                url: ':slug/dashboard',
                templateUrl: '/views/profile/profile.dashboard.html'
                controller : 'MakerScienceProfileCtrl'
                ncyBreadcrumb:
                    label: 'Espace personnel'
                    parent : 'profile.detail'
        )
        .state('map',
                url: '/map/',
                templateUrl: '/views/map/map.html'
                ncyBreadcrumb:
                    label: 'Carte de la communauté'
                    parent : 'profile.list'
        )
        .state('about',
                url: '/about/',
                templateUrl: '/views/base/about.html'
                ncyBreadcrumb:
                    label: 'A propos'
                    parent : 'home'
        )
        .state('forum',
                url: '/discussions/',
                templateUrl: '/views/forum/forum.html'
                controller : 'MakerScienceForumCtrl'
                ncyBreadcrumb:
                    label: 'Discussions'
                    parent : 'home'
        )
        .state('question',
                url: '/discussions/:slug',
                templateUrl: '/views/forum/thread.display.html'
                controller : 'MakerSciencePostCtrl'
                ncyBreadcrumb:
                    label: '{{post.title}}'
                    parent : 'forum'
        )
        .state('tags',
                url: '/tags/',
                templateUrl: '/views/base/tag_listing.html'
                ncyBreadcrumb:
                    label: 'Tags'
                    parent : 'home'
        )
        .state('tag',
                url: '/tag/:slug',
                templateUrl: '/views/base/tagged_objects.html'
                controller : 'MakerScienceSearchCtrl'
                ncyBreadcrumb:
                    label: '{{tag.slug}}'
                    parent : 'tags'
        )
        .state('search',
                url: '/search/:q',
                templateUrl: '/views/base/search_result.html'
                controller : 'MakerScienceSearchCtrl'
                ncyBreadcrumb:
                    label: 'Recherche'
                    parent : 'home'
        )

])
.run(($rootScope, $location, editableOptions, editableThemes, amMoment, $state, $stateParams, loginService, CurrentMakerScienceProfileService, $sce) ->
    editableOptions.theme = 'bs3'
    editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary">Enregistrer</button>'
    editableThemes['bs3'].cancelTpl = '<button type="button" class="btn btn-default" ng-click="$form.$cancel()">Annuler</button>'

    amMoment.changeLocale('fr')
    $rootScope.CurrentMakerScienceProfileService = CurrentMakerScienceProfileService
    $rootScope.loginService = loginService
    $rootScope.config = config
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams

    $rootScope.Math = window.Math

    $rootScope.location = $location

    $rootScope.tinyMceOptions = {
        plugins: ["advlist autolink autosave link image lists anchor wordcount  code fullscreen insertdatetime media nonbreaking"],
        toolbar1: "italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist |outdent indent blockquote | link unlink anchor",
        menubar: false,
        statusbar: false,
        toolbar_items_size: 'small',
        language_url: "/js/tinymce_fr_FR.js",
        language: "fr_FR",
    }

    $rootScope.trustAsHtml = (string) ->
        return $sce.trustAsHtml(string)

)

angular.module('xeditable').directive('editableTextAngular', ['editableDirectiveFactory', (editableDirectiveFactory) ->
    return editableDirectiveFactory(
            directiveName : 'editableTextAngular'
            inputTpl : '<div text-angular></div>'
    )]
)
