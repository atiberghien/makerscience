module = angular.module('commons.community.controllers', [])

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

    $scope.communityObjectTypeName = $scope.objectTypeName
    $scope.communityObjectID = $scope.objectId

    return ObjectProfileLink.one().customGETLIST($scope.communityObjectTypeName+'/'+$scope.communityObjectID).then((objectProfileLinkResults) ->
        $scope.community = objectProfileLinkResults
        # angular.forEach($scope.community, (member) ->
        #     console.log(member.profile.user.email, member.level)
        # )

        $scope.addMember = (profile, level, detail, isValidated)->
            if $scope.isAlreadyMember(profile, level)
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

        return $scope.community
    )

)
