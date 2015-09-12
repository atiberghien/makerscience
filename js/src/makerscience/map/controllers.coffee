module = angular.module("makerscience.map.controllers", [])

module.run(['$anchorScroll', ($anchorScroll) ->
  $anchorScroll.yOffset = 50
])

module.controller("MakerScienceMapCtrl", ($scope, $anchorScroll, $location, $controller, leafletData, leafletEvents, geocoderService, MakerScienceProfileLight, MakerScienceProjectLight, ObjectProfileLink) ->
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {$scope: $scope}))

    $scope.gotoAnchor = (x) ->
        newHash = 'anchor' + x
        if $location.hash() != newHash
            $location.hash('anchor' + x)
        else
            $anchorScroll()

    $scope.spottedProfile = null
    $scope.showMemberInfo = false

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
        markers : {}
    )

    MakerScienceProfileLight.one().customGETLIST('search', $scope.params).then((profileResults) ->
        angular.forEach(profileResults, (profile) ->
            geocoderService.getLatLong(profile.address_locality).then((latlng)->
                icon =
                    shadowUrl: '/img/users/user-shadow.png'
                    iconSize: [30, 30]
                    shadowSize:   [44, 44]
                    iconAnchor:   [15, 15]
                    shadowAnchor: [22, 22]
                if profile.avatar
                    icon["iconUrl"] = profile.avatar
                else
                    icon["iconUrl"] = '/img/avatar.png'

                $scope.markers[profile.id]=
                    slug : profile.slug
                    group: "center"
                    groupOption :
                        showCoverageOnHover : false
                    lat: latlng.lat()
                    lng: latlng.lng()
                    draggable: false
                    icon: icon
                    icon_standard : icon
                    icon_hover:
                        iconUrl: '/img/avatar.png'
                        shadowUrl: 'img/users/user-shadow.png'
                        iconSize: [52, 51]
                        shadowSize:   [67, 67]
                        iconAnchor:   [25, 25]
                        shadowAnchor: [33, 33]
                if profile.avatar
                    $scope.markers[profile.id]["icon_hover"]["iconUrl"] = profile.avatar
                else
                    $scope.markers[profile.id]["icon_hover"]["iconUrl"] = '/img/avatar.png'
            )
        )
    )
    $scope.$on('leafletDirectiveMarker.click', (event, args) ->
        marker = $scope.markers[args.modelName]
        marker.icon = marker.icon_hover

        MakerScienceProfileLight.one(marker.slug).get().then((profileResult)->
            $scope.spottedProfile = profileResult
            $scope.spottedProfile.projects = []

            ObjectProfileLink.getList({level : 0, profile__id : $scope.spottedProfile.parent_id}).then((linkedProjectResults)->
                angular.forEach(linkedProjectResults, (linkedProject) ->
                    MakerScienceProjectLight.one().get({id : linkedProject.object_id}).then((makerscienceProjectResults) ->
                        if makerscienceProjectResults.objects.length == 1
                            $scope.spottedProfile.projects.push(makerscienceProjectResults.objects[0])
                    )
                )
            )
            $scope.showMemberInfo = true
        )
    )

    $scope.$on("leafletDirectiveMap.click", (event, args) ->
        if $scope.spottedProfile
            marker = $scope.markers[$scope.spottedProfile.id]
            marker.icon = marker.icon_standard
            $scope.spottedProfile = null
        $scope.showMemberInfo = false
    )
)
