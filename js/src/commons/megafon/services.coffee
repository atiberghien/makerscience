module = angular.module("commons.megafon.services", ['restangular'])

# Services
module.factory('Post', (Restangular) ->
    return Restangular.service('megafon/post')
)
