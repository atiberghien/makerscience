module = angular.module("commons.ucomment.services", ['restangular'])

# Services
module.factory('Comment', (Restangular) ->
    return Restangular.service('comment')
)

