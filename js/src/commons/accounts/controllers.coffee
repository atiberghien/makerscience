module = angular.module("commons.accounts.controllers", ['commons.accounts.services', 'commons.base.services'])

module.controller("CommunityCtrl", ($scope, Profile, ObjectProfileLink, DataSharing) ->
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
    $scope.currentUserCandidate = false
    $scope.community = []

    $scope.init = (objectTypeName) ->
        console.log("init community ctrler")
        $scope.addMember = (profile, level, detail, isValidated)->
            console.log(" Profile ?", profile)
            if $scope.isAlreadyMember(profile, level)
                console.log(" --- ! -- already Member with this level --- ! ---")
                return true
            ObjectProfileLink.one().customPOST(
                profile_id: profile.id,
                level: level,
                detail : detail,
                isValidated:isValidated
            , $scope.objectTypeName+'/'+$scope.object.id).then((objectProfileLinkResult) ->
                $scope.community.push(objectProfileLinkResult)
            )

        $scope.isAlreadyMember = (profile, level)->
            # Check if selected profile is not already added with given level
            for member in $scope.community
                if member.profile.resource_uri == profile.resource_uri
                    if member.level == level
                        return true
            return false

        $scope.removeMember = (member) ->
            # attention confusion possible : member ici correspond à une instance de
            # ObjectProfileLink. L'id du profil concerné e.g se trouve à member.profile.id
            ObjectProfileLink.one(member.id).remove().then(()->
                memberIndex = $scope.community.indexOf(member)
                $scope.community.splice(memberIndex, 1)
            )

        $scope.validateMember = ($event, member) ->
            validated = $event.target.checked
            console.log(" Validating ?? !", validated)
            ObjectProfileLink.one(member.id).patch({isValidated : validated}).then(
                memberIndex = $scope.community.indexOf(member)
                member = $scope.community[memberIndex]
                member.isValidated = validated
                )

        $scope.updateMemberDetail = (detail, member) ->
            ObjectProfileLink.one(member.id).patch({detail : detail}).then(
                memberIndex = $scope.community.indexOf(member)
                member = $scope.community[memberIndex]
                member.detail = detail
                )

        $scope.objectTypeName = objectTypeName
        console.log(" Shared Object ? ", DataSharing.sharedObject)
        $scope.object = DataSharing.sharedObject[$scope.objectTypeName]
        if $scope.object
            $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        $scope.$watch(
            ()->
                return DataSharing.sharedObject
            ,(newVal, oldVal) ->
                console.log(" Updating Shared Object : new ="+newVal+" old = "+oldVal)
                if newVal != oldVal
                    $scope.object = newVal[$scope.objectTypeName]
                    $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        )
)
