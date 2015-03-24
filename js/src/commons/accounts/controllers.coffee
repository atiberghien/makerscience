module = angular.module("commons.accounts.controllers", ['commons.accounts.services', 'makerscience.base.services'])

module.controller("CommunityCtrl", ($scope, Profile, ObjectProfileLink, DataSharing) ->
    """
    Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )
    La sémantique des niveaux d'implication est à préciser en fonction de la resource.
    A titre d'exemple, pour les projets et fiche ressource MakerScience :
    - 0 -> Membre de l'équipe projet
    - 1 -> personne ressource
    - 2 -> fan/follower
    """

    $scope.profiles = Profile.getList().$object
    $scope.teamCandidate = null
    $scope.resourceCandidate = null
    $scope.currentUserCandidate = false
    $scope.community = []

    $scope.init = (objectTypeName) ->

        #$scope.$on(objectTypeName+'Ready', (event, args) ->
        $scope.addMember = (profile, level, detail, isValidated)->
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
        #$scope.object = args[objectTypeName]
        console.log(" Shared Object ? ", DataSharing.sharedObject)
        # assign it right away ( if parent ctrler has already rendered, we get it NOW)
        $scope.object = DataSharing.sharedObject
        # AND watch changes (if parent ctrl has not yet rendered, we WILL get it)
        $scope.$watch('DataSharing.sharedObject', (newVal, oldVal, scope) ->
            if newVal
                console.log(" Updating Shared Object ", newVal)
                $scope.object = newVal
                $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        )
        if $scope.object
            $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        #)
)
