module = angular.module("commons.accounts.controllers", ['commons.accounts.services'])

module.controller("CommunityCtrl", ($scope, $rootScope, ObjectProfileLink) ->
    """
    Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )
    dépend des data suivantes chargées dans le scope parent:
    - $scope.resource_type
    - $scope.resource_id 
    La sémantique des niveaux d'implication est à préciser en fonction de la resource.
    A titre d'exemple, pour les projets et fiche ressource MakerScience :
    - 0 -> Membre de l'équipe projet
    - 1 -> personne ressource
    - 2 -> fan/follower
    """
    $scope.community = ObjectProfileLink.one().customGETLIST($scope.resource_type+'/'+$scope.resource_id).$object
        
    $scope.addMember = (profileId, level, detail)->
        return true

)