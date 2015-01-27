module = angular.module("makerscience.map.controllers", [])

module.controller("MakerScienceMapCtrl", ($scope, leafletData) ->

    # define user's icons
    user_icons =
            user_default:
                iconUrl: 'img/users/user-default.png' # Used when we don't have a photo for the user
                shadowUrl: 'img/users/user-shadow.png'
                iconSize: [30, 30]
                shadowSize:   [44, 44]
                iconAnchor:   [15, 15]
                shadowAnchor: [22, 22]
                
            # Small icon
            user_01:
                iconUrl: 'img/users/user-mathieu.png' # The only parameter that will need to change and be fetched dynamically
                shadowUrl: 'img/users/user-shadow.png'
                iconSize: [30, 30]
                shadowSize:   [44, 44]
                iconAnchor:   [15, 15]
                shadowAnchor: [22, 22]
                
            # Large icon
            user_01_hover:
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
                group: "center"
                lat: 44.5175
                lng: 3.5
                message: "The MakerScience dev squad"
                draggable: false
                icon: user_icons.user_default
            capitalParis:
                group: "center"
                lat: 48.854755
                lng: 2.347246
                message: "Paris"
                draggable: false
                icon: user_icons.user_01
            user02:
                group: "center"
                lat: 48.84
                lng: 2.35
                message: "User 02"
                draggable: false
                icon: user_icons.user_default
            user03:
                group: "center"
                lat: 48.81
                lng: 2.30
                message: "User 03"
                draggable: false
                icon: user_icons.user_default
    )
)
