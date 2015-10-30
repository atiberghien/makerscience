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
                                'sticky', 'mentio', 'ui.tinymce', 'ngImgCrop', 'vcRecaptcha', 'infinite-scroll'])

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

.config(($authProvider) ->
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

    # $authProvider.twitter({
    #     url : config.loginBaseUrl + '/account/user/login/twitter',
    # })


)

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
        $stateProvider.state('404',
                url: '/',
                templateUrl: 'views/404.html',
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
                controller : 'MakerScienceProjectListCtrl'
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
                controller : 'MakerScienceResourceListCtrl'
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
                controller : 'MakerScienceProfileListCtrl'
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
                controller : 'MakerScienceProfileDashboardCtrl'
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
                    label: '{{post.parent.title}}'
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
        .state('resetPassword',
                url: '/reset/password/:hash/?email',
                templateUrl: '/views/reset_password.html'
                controller : 'MakerScienceResetPasswordCtrl'
                ncyBreadcrumb:
                    label: 'Ré-initialisation de mot de passe'
                    parent : 'home'
        )
        .state('cgu',
                url: '/cgu',
                templateUrl: '/views/cgu.html'
                controller : 'StaticContentCtrl'
                ncyBreadcrumb:
                    label: "Conditions d’utilisation"
                    parent : 'home'
        )
        .state('mentions',
                url: '/mentions-legales',
                templateUrl: '/views/mentions.html'
                controller : 'StaticContentCtrl'
                ncyBreadcrumb:
                    label: "Mentions Légales"
                    parent : 'home'
        )
        # .state('twitter',
        #         url: '/auth/twitter',
        #         # templateUrl: 'closePopup.html'
        #         controller : 'TwitterAuthCtrl'
        # )

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

    $rootScope.tinyMceFullOptions = {
        plugins: ["advlist autolink autosave link image lists anchor wordcount  code fullscreen insertdatetime media nonbreaking"],
        toolbar1: "styleselect | italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist |outdent indent blockquote | link unlink anchor | media",
        menubar: false,
        statusbar: false,
        toolbar_items_size: 'small',
        language_url: "/js/tinymce_fr_FR.js",
        language: "fr_FR",
        style_formats: [
            {title: "Titre", items: [
                {title: "Titre 1", format: "h1"},
                {title: "Titre 2", format: "h2"},
                {title: "Titre 3", format: "h3"},
                {title: "Titre 4", format: "h4"},
                {title: "Titre 5", format: "h5"},
                {title: "Titre 6", format: "h6"}
            ]},
        ]
    }

    $rootScope.$on('$stateChangeSuccess', () ->
        document.body.scrollTop = document.documentElement.scrollTop = 0;
    )

    $rootScope.trustAsHtml = (string) ->
        return $sce.trustAsHtml(string)

    $rootScope.recaptchaKey = "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"

)

angular.module('xeditable').directive('editableTextAngular', ['editableDirectiveFactory', (editableDirectiveFactory) ->
    return editableDirectiveFactory(
            directiveName : 'editableTextAngular'
            inputTpl : '<div text-angular></div>'
    )]
)
