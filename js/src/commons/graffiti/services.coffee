module = angular.module("commons.graffiti.services", ['restangular'])


# Services
module.factory('Tag', (Restangular) ->
    return Restangular.service('tag')
)
module.factory('TaggedItem', (Restangular) ->
    return Restangular.service('taggeditem')
)
