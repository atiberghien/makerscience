module = angular.module("makerscience.base.services", ['restangular'])

module.factory('StaticContent', (Restangular) ->
    return Restangular.service('makerscience/static')
)
