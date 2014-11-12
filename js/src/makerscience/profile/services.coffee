module = angular.module("makerscience.profile.services", [])


# Services
module.factory('MakerScienceProfile', (Restangular) ->
    return Restangular.service('makerscience/profile')
)
