module = angular.module("commons.starlet.services", ['restangular'])


# Services
module.factory('Vote', (Restangular) ->
    return Restangular.service('vote')
)
