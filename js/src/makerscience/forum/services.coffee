module = angular.module("makerscience.forum.services", ['restangular'])


# Services
module.factory('MakerSciencePost', (Restangular) ->
    return Restangular.service('makerscience/post')
)
