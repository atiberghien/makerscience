module = angular.module("makerscience.map.controllers", [])

module.controller("MakerScienceMapCtrl", ($scope, leafletData) ->
    angular.extend($scope,
        defaults :
            scrollWheelZoom: false # keep the scrolling working on the page, not in the map
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
        markers:
            devTeam:
                lat: 44.5175
                lng: 3.5
                message: "The MakerScience dev squad"
                draggable: false
            capitalParis:
                iconUrl: 'img/location.png'
                lat: 48.854755
                lng: 2.347246
                message: "Paris"
                draggable: false
    )
)
