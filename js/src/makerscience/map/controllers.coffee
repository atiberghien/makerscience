module = angular.module("makerscience.map.controllers", [])

module.controller("MakerScienceMapCtrl", ($scope, leafletData) ->
    user_icons =
            user_default:
                iconUrl: 'img/users/user-default.png' # Used when we don't have a photo for the user
                shadowUrl: 'img/users/user-shadow.png'
                iconSize: [52, 51]
                shadowSize:   [67, 67]
                iconAnchor:   [25, 25]
                shadowAnchor: [33, 33]
            user_01:
                iconUrl: 'img/users/user-mathieu.png' # The only parameter that will need to change and be fetched dynamically
                shadowUrl: 'img/users/user-shadow.png'
                iconSize: [52, 51]
                shadowSize:   [67, 67]
                iconAnchor:   [25, 25]
                shadowAnchor: [33, 33]
    angular.extend($scope,
        defaults :
            scrollWheelZoom: false # Keep the scrolling working on the page, not in the map
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
                icon: user_icons.user_default
            capitalParis:
                lat: 48.854755
                lng: 2.347246
                message: "Paris"
                draggable: false
                icon: user_icons.user_01
            user02:
                lat: 48.84
                lng: 2.35
                message: "User 02"
                draggable: false
                icon: user_icons.user_default
            user03:
                lat: 48.81
                lng: 2.30
                message: "User 03"
                draggable: false
                icon: user_icons.user_default
    )
)
