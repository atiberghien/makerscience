module = angular.module("commons.accounts.controllers", ['commons.accounts.services'])

module.controller("CommunityCtrl", ($scope, Profile, ObjectProfileLink) ->
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
    $scope.community = []

    $scope.init = (objectTypeName) ->

        $scope.$on(objectTypeName+'Ready', (event, args) ->
            $scope.addMember = (profile, level, detail, isValidated)->
                ObjectProfileLink.one().customPOST(
                    profile:profile,
                    level: level,
                    detail : detail,
                    isValidated:isValidated
                , $scope.objectTypeName+'/'+$scope.object.id).then((objectProfileLinkResult) ->
                    $scope.community.push(objectProfileLinkResult)
                )

            $scope.removeMember = (member) ->
                ObjectProfileLink.one(member.id).remove().then(()->
                    memberIndex = $scope.community.indexOf(member)
                    $scope.community.splice(memberIndex, 1)
                )

            $scope.objectTypeName = objectTypeName
            $scope.object = args[objectTypeName]
            $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        )
)
