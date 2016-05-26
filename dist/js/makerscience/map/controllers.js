(function() {
  var module;

  module = angular.module("makerscience.map.controllers", []);

  module.run([
    '$anchorScroll', function($anchorScroll) {
      return $anchorScroll.yOffset = 50;
    }
  ]);

  module.controller("MakerScienceMapCtrl", function($scope, $anchorScroll, $location, $controller, leafletData, leafletEvents, geocoderService, MakerScienceProfileLight, MakerScienceProjectLight, ObjectProfileLink) {
    angular.extend(this, $controller('MakerScienceAbstractListCtrl', {
      $scope: $scope
    }));
    $scope.gotoAnchor = function(x) {
      var newHash;
      newHash = 'anchor' + x;
      if ($location.hash() !== newHash) {
        return $location.hash('anchor' + x);
      } else {
        return $anchorScroll();
      }
    };
    $scope.spottedProfile = null;
    $scope.showMemberInfo = false;
    angular.extend($scope, {
      defaults: {
        scrollWheelZoom: true,
        maxZoom: 14,
        minZoom: 5,
        path: {
          weight: 10,
          color: '#800000',
          opacity: 1
        }
      },
      center: {
        lat: 46.43,
        lng: 2.35,
        zoom: 5
      },
      markers: {}
    });
    MakerScienceProfileLight.one().customGETLIST('search', {
      limit: 0
    }).then(function(profileResults) {
      return angular.forEach(profileResults, function(profile) {
        var icon;
        if (profile.lng && profile.lat) {
          icon = {
            shadowUrl: '/img/users/user-shadow.png',
            iconSize: [30, 30],
            shadowSize: [44, 44],
            iconAnchor: [15, 15],
            shadowAnchor: [22, 22]
          };
          if (profile.avatar) {
            icon["iconUrl"] = profile.avatar;
          } else {
            icon["iconUrl"] = '/img/avatar.png';
          }
          $scope.markers[profile.id] = {
            slug: profile.slug,
            group: "center",
            groupOption: {
              showCoverageOnHover: false
            },
            lat: profile.lat,
            lng: profile.lng,
            draggable: false,
            icon: icon,
            icon_standard: icon,
            icon_hover: {
              iconUrl: '/img/avatar.png',
              shadowUrl: 'img/users/user-shadow.png',
              iconSize: [52, 51],
              shadowSize: [67, 67],
              iconAnchor: [25, 25],
              shadowAnchor: [33, 33]
            }
          };
          if (profile.avatar) {
            return $scope.markers[profile.id]["icon_hover"]["iconUrl"] = profile.avatar;
          } else {
            return $scope.markers[profile.id]["icon_hover"]["iconUrl"] = '/img/avatar.png';
          }
        }
      });
    });
    $scope.$on('leafletDirectiveMarker.click', function(event, args) {
      var marker;
      if ($scope.spottedProfile) {
        marker = $scope.markers[$scope.spottedProfile.id];
        marker.icon = marker.icon_standard;
        $scope.spottedProfile = null;
      }
      marker = $scope.markers[args.modelName];
      marker.icon = marker.icon_hover;
      return MakerScienceProfileLight.one(marker.slug).get().then(function(profileResult) {
        $scope.spottedProfile = profileResult;
        $scope.spottedProfile.projects = [];
        ObjectProfileLink.getList({
          level: 0,
          profile__id: $scope.spottedProfile.parent_id
        }).then(function(linkedProjectResults) {
          return angular.forEach(linkedProjectResults, function(linkedProject) {
            return MakerScienceProjectLight.one().get({
              id: linkedProject.object_id
            }).then(function(makerscienceProjectResults) {
              if (makerscienceProjectResults.objects.length === 1) {
                return $scope.spottedProfile.projects.push(makerscienceProjectResults.objects[0]);
              }
            });
          });
        });
        return $scope.showMemberInfo = true;
      });
    });
    return $scope.$on("leafletDirectiveMap.click", function(event, args) {
      var marker;
      if ($scope.spottedProfile) {
        marker = $scope.markers[$scope.spottedProfile.id];
        marker.icon = marker.icon_standard;
        $scope.spottedProfile = null;
      }
      return $scope.showMemberInfo = false;
    });
  });

}).call(this);
