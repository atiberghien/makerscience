module = angular.module("makerscience.catalog.services", ['restangular'])


# Services
module.factory('MakerScienceProject', (Restangular) ->
    return Restangular.service('makercience/project')
)
