angular.module('commons.accounts', ['commons.accounts.services', 'commons.accounts.controllers'])
angular.module('commons.ucomment', ['commons.ucomment.controllers', 'commons.ucomment.services', 'commons.ucomment.directives'])
angular.module('commons.megafon', ['commons.megafon.controllers', 'commons.megafon.services'])
angular.module('commons.starlet', ['commons.starlet.controllers', 'commons.starlet.services'])
angular.module('commons.scout', ['commons.scout.services'])
angular.module('commons.form', ['commons.form.services'])
angular.module('commons.community', ['commons.community.controllers', 'commons.community.directives'])
angular.module('commons.gallery', ['commons.gallery.services', 'commons.gallery.controllers', 'commons.gallery.directives'])
angular.module('commons.tags', ['commons.tags.directives', 'commons.tags.controllers', 'commons.tags.services'])
angular.module('commons.directives', ['commons.directives.reportabuse' ,'commons.directives.inputfile', 'commons.directives.thumb',
                                      'commons.directives.socialshare', 'commons.directives.cover', 'commons.directives.avatar'])
angular.module('makerscience.projects', ['makerscience.projects.controllers', 'makerscience.projects.services','makerscience.projects.directives'])
angular.module('makerscience.resources', ['makerscience.resources.controllers'])
angular.module('makerscience.profile', ['makerscience.profile.controllers', 'makerscience.profile.services', 'makerscience.profile.directives'])
angular.module('makerscience.base', ['makerscience.base.controllers', 'makerscience.base.services', 'makerscience.base.filters'])
angular.module('makerscience.map', ['makerscience.map.controllers'])
angular.module('makerscience.forum', ['makerscience.forum.controllers', 'makerscience.forum.services', 'makerscience.forum.directives'])
app = angular.module('makerscience', ['commons.accounts', 'commons.community', 'commons.gallery', 'commons.tags', 'commons.scout', 'commons.ucomment', 'commons.directives', 'commons.form',
                                'makerscience.projects', 'makerscience.resources', 'makerscience.profile', "makerscience.forum",
                                'makerscience.base','makerscience.map', 'commons.megafon', 'commons.starlet',
                                'restangular', 'ui.bootstrap', 'ui.router', 'ui.unique', 'xeditable', 'angularFileUpload',
                                'ngSanitize', 'ngTagsInput', 'angularMoment', 'leaflet-directive', "angucomplete-alt", "videosharing-embed"
                                'geocoder-service', 'ncy-angular-breadcrumb', 'truncate', 'satellizer', 'ngCookies', '720kb.socialshare',
                                'sticky', 'mentio', 'ui.tinymce', 'ngImgCrop', 'vcRecaptcha', 'infinite-scroll', 'angular-confirm'])

# CORS

.constant('Config', config)
.config(($httpProvider) ->
        $httpProvider.defaults.useXDomain = true;
        delete $httpProvider.defaults.headers.common["X-Requested-With"];
)
# Tastypie
.config((RestangularProvider) ->
        RestangularProvider.setBaseUrl(config.rest_uri)
        RestangularProvider.setRequestSuffix('?format=json')
        # Tastypie patch
        # RestangularProvider.setMethodOverriders(["put", "patch", "delete"])
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
        clientId: config.facebook.clientId,
        scope: ['email', 'public_profile']
    })

    $authProvider.google({
        url: config.loginBaseUrl + '/account/user/login/google',
        clientId: config.google.clientId,
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
        .state('404',
                url: '/',
                templateUrl: 'views/404.html',
        )
        .state('project',
                url: '/p/'
                abstract: true,
                templateUrl : '/views/project/project.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('project.list',
                url: 'list',
                templateUrl: '/views/project/project.list.html',
                controller : 'MakerScienceProjectListCtrl'
                ncyBreadcrumb:
                    label: 'Projets'
        )
        .state('project.form',
                url: 'new',
                templateUrl: '/views/project/project.form.html',
                controller : 'MakerScienceProjectSheetCreateCtrl'
                ncyBreadcrumb:
                    label: 'Nouveau projet'
                    parent : 'project.list'
                loginRequired : true
        )
        .state('project.detail',
                url: ':slug',
                templateUrl: '/views/project/project.detail.base.html',
                controller : 'MakerScienceProjectSheetCtrl'
                ncyBreadcrumb:
                    label: '{{projectsheet.parent.title}}'
                    parent : 'project.list'
        )
        .state('resource',
                url : '/r/',
                abstract : true,
                templateUrl : '/views/resource/resource.html'
                controller : 'MakerScienceResourceListCtrl'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('resource.list',
                url: 'list',
                templateUrl: '/views/resource/resource.list.html'
                ncyBreadcrumb:
                    label: 'Ressources'
        )
        .state('resource.form',
                url: 'new',
                templateUrl: '/views/resource/resource.form.html'
                controller : 'MakerScienceResourceSheetCreateCtrl'
                ncyBreadcrumb:
                    label: 'Nouvelle expérience'
                    parent : 'resource.list'
                loginRequired : true
        )
        .state('resource.detail',
                url: ':slug',
                templateUrl: '/views/resource/resource.detail.base.html'
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

])
.run(($rootScope, $location, editableOptions, editableThemes, $confirmModalDefaults, amMoment, $state, $stateParams, loginService, CurrentMakerScienceProfileService, $sce) ->
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
        plugins: ["placeholder advlist autolink autosave link image lists anchor wordcount  code fullscreen insertdatetime media nonbreaking"],
        toolbar1: "italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist |outdent indent blockquote | link unlink anchor",
        menubar: false,
        statusbar: false,
        toolbar_items_size: 'small',
        language_url: "/js/tinymce_fr_FR.js",
        language: "fr_FR",
        content_style: "p {color: #535353; font-size: 1.2em}",
    }

    $rootScope.tinyMceFullOptions = {
        plugins: ["placeholder advlist autolink autosave link image lists anchor wordcount code fullscreen insertdatetime nonbreaking"],
        toolbar1: "styleselect | italic underline strikethrough | alignleft aligncenter alignjustify | bullist numlist |outdent indent | link unlink anchor |  image | removeformat code",
        menubar: false,
        statusbar: false,
        toolbar_items_size: 'small',
        language_url: "/js/tinymce_fr_FR.js",
        language: "fr_FR",
        content_style: "p {color: #535353; font-size: 1.2em}",
        style_formats: [
            {title: "Titre", items: [
                {title: "Titre 1", format: "h1"},
                {title: "Titre 2", format: "h2"},
                {title: "Titre 3", format: "h3"},
                {title: "Titre 4", format: "h4"},
                {title: "Titre 5", format: "h5"},
                {title: "Titre 6", format: "h6"}
            ]},
        ],
    }

    $rootScope.$on('$stateChangeSuccess', () ->
        document.body.scrollTop = document.documentElement.scrollTop = 0;
    )

    $rootScope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams, options) ->
        $rootScope.afterLoginState = null
        $rootScope.beforeLoginState = null
        if(toState.loginRequired && !$rootScope.authVars.isAuthenticated)
            $rootScope.afterLoginState = toState
            $rootScope.beforeLoginState = fromState
            $rootScope.authVars.loginrequired = true
            event.preventDefault();
    )

    $rootScope.trustAsHtml = (string) ->
        return $sce.trustAsHtml(string)

    $rootScope.recaptchaKey = config.google.recaptchaKey

    $confirmModalDefaults.templateUrl = 'views/base/confirmModal.html';

)

angular.module('xeditable').directive('editableTinyAngular', ['editableDirectiveFactory', (editableDirectiveFactory) ->
    return editableDirectiveFactory(
            directiveName : 'editableTinyAngular'
            inputTpl : '<textarea ui-tinymce="tinyMceFullOptions" ng-trim="false"></textarea>'
    )]
)
