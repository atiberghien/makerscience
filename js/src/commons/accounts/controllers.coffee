module = angular.module("commons.accounts.controllers", ['commons.accounts.services', 'makerscience.base.services'])

module.controller("CommunityCtrl", ($scope, $filter, $interval, Profile, ObjectProfileLink) ->
    """
    Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )
    La sémantique des niveaux d'implication est à préciser en fonction de la resource.
    A titre d'exemple, pour les projets et fiche ressource MakerScience :
    - 0 -> Membre de l'équipe projet
    - 1 -> personne ressource
    - 2 -> fan/follower

    NB. les objets "profile" manipulé ici sont les profils génériques du dataserver (et non les MakerScienceProfile)
        dispo à api/v0/accounts/profile (cf service "Profile")
    """

    $scope.profiles = Profile.getList().$object
    $scope.teamCandidate = null
    $scope.resourceCandidate = null

    $scope.initCommunityCtrl = (objectTypeName, objectID) ->
        $scope.communityObjectTypeName = objectTypeName
        $scope.communityObjectID = objectID

        $scope.community = ObjectProfileLink.one().customGETLIST($scope.communityObjectTypeName+'/'+$scope.communityObjectID).$object

        $scope.addMember = (profile, level, detail, isValidated)->
            if $scope.isAlreadyMember(profile, level)
                console.log(" --- ! -- already Member with this level --- ! ---")
                return true
            ObjectProfileLink.one().customPOST(
                profile_id: profile.id,
                level: level,
                detail : detail,
                isValidated:isValidated
            , $scope.communityObjectTypeName+'/'+$scope.communityObjectID).then((objectProfileLinkResult) ->
                $scope.community.push(objectProfileLinkResult)
            )

        $scope.isAlreadyMember = (profile, level) ->
            return profile && $filter('filter')($scope.community, {$:profile.resource_uri, level:level, isValidated: true}).length == 1

        $scope.removeMember = (member) ->
            # attention confusion possible : member ici correspond à une instance de
            # ObjectProfileLink. L'id du profil concerné e.g se trouve à member.profile.id
            ObjectProfileLink.one(member.id).remove().then(()->
                memberIndex = $scope.community.indexOf(member)
                $scope.community.splice(memberIndex, 1)
                if (member.level == 0 || member.level == 10) && member.profile.id == $scope.currentMakerScienceProfile.parent.id
                    $scope.editable = false
            )

        $scope.deleteMember = (profile, level) ->
            ObjectProfileLink.one().customGET($scope.communityObjectTypeName+'/'+$scope.communityObjectID, {profile_id:profile.id, level:level}).then((objectProfileLinkResults)->
                angular.forEach(objectProfileLinkResults.objects, (link) ->
                    $scope.removeMember(link)
                )
            )

        $scope.validateMember = (member, isValidated) ->
            data = {isValidated : isValidated}
            if member.level == 5
                member.level = data["level"] = 0
                member.detail = data["detail"] = ""
            else if member.level == 6
                member.level = data["level"] = 1
                member.detail = data["detail"] = ""
            else if member.level == 15
                member.level = data["level"] = 10
                member.detail = data["detail"] = ""
            else if member.level == 16
                member.level = data["level"] = 11
                member.detail = data["detail"] = ""

            ObjectProfileLink.one(member.id).patch(data).then(()->
                memberIndex = $scope.community.indexOf(member)
                member = $scope.community[memberIndex]
                member.isValidated = isValidated
                if (member.level == 0 || member.level == 10) && member.profile.id == $scope.currentMakerScienceProfile.parent.id
                    $scope.editable = isValidated
            )

        $scope.updateMemberDetail = (detail, member) ->
            ObjectProfileLink.one(member.id).patch({detail : detail}).then(()->
                memberIndex = $scope.community.indexOf(member)
                member = $scope.community[memberIndex]
                member.detail = detail
                return true
            )
            return false

        $scope.showTeamMembersFilter = (member) ->
            return member.level == 0 || member.level== 5

        $scope.showHelpersFilter = (member) ->
            return member.level == 1 || member.level== 6

        $scope.showCoAuthorsFilter = (member) ->
            return member.level == 10 || member.level== 15

        $scope.showSimilarsFilter = (member) ->
            return member.level == 11 || member.level== 16


)

module.controller('LoginCtrl', ($scope, $rootScope, $state, $stateParams, $cookies, $http, $auth) ->

    $scope.authenticate = (provider) ->
        if provider == 'basic'

            $rootScope.authVars.username = asmCrypto.SHA1.hex($scope.basicEmail).slice(0,30)
            $rootScope.authVars.password = $scope.basicPassword
            $rootScope.loginService.submit()
            # $scope.basicEmail = ""
            # $scope.basicPassword = ""
        else
            $auth.authenticate(provider).then((response) ->
                if response.data.success
                    $cookies.username = response.data.username
                    $cookies.key = response.data.token
                    $http.defaults.headers.common['Authorization'] = "ApiKey #{response.data.username}:#{response.data.token}"
                    $rootScope.$broadcast('event:auth-loginConfirmed')
                    $state.go($state.current.name, $stateParams)
            )
)

# module.controller('TwitterAuthCtrl', ($scope, $rootScope, $location, $state, $stateParams, $cookies, $http, $auth, User) ->
#     getParams = $location.search()
#     oauth_token = getParams['oauth_token']
#     oauth_verifier = getParams['oauth_verifier']
#
#     User.one().customGET('login/twitter/authenticated', $location.search()).then((response)->
#         console.log(response)
#         if response.success
#             $cookies.username = response.username
#             $cookies.key = response.token
#             $http.defaults.headers.common['Authorization'] = "ApiKey #{response.username}:#{response.token}"
#             $rootScope.$broadcast('event:auth-loginConfirmed')
#             $state.go($state.current.name, $stateParams)
#     )
# )
