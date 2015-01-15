module = angular.module("makerscience.map.controllers", [])

module.controller("MakerScienceMapCtrl", ($scope, leafletData) ->
    angular.extend($scope,
        defaults :
            maxZoom: 14
            minZoom: 5
            path:
                weight: 10
                color: '#800000'
                opacity: 1
        center:
            lat: 46.43
            lng: 2.35
            zoom: 5
    )
)
