module = angular.module("makerscience.catalog.controllers", [])

module.controller("MakerscienceProjectSheetCreateCtrl", ($scope, $controller) ->
    console.log("MakerscienceProjectSheetCreateCtrl")
    $controller('ProjectSheetCreateCtrl', {$scope: $scope});
    
    
    $scope.loadTags = (query) ->
        tags = [
            "text" : "créativité",
            "text" : "workshop",
            "text" : "géologie",
            "text" : "hydrologie",
            "text" : "numérique",
            "text" : "réalité",
            "text" : "augmentée"
        ]
        return tags;
)