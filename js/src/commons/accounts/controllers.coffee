module = angular.module("commons.accounts.controllers", ['commons.accounts.services'])

module.controller("CommunityCtrl", ($scope, ObjectProfileLink) ->
    """
    Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )
    La sémantique des niveaux d'implication est à préciser en fonction de la resource.
    A titre d'exemple, pour les projets et fiche ressource MakerScience :
    - 0 -> Membre de l'équipe projet
    - 1 -> personne ressource
    - 2 -> fan/follower
    """

    $scope.addMember = (profileId, level, detail)->
        return true

)
