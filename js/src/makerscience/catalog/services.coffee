module = angular.module("makerscience.catalog.services", ['restangular'])


# Services
module.factory('MakerScienceProject', (Restangular) ->
    return Restangular.service('makerscience/project')
)

module.factory('MakerScienceResource', (Restangular) ->
    return Restangular.service('makerscience/resource')
)

module.factory('MakerScienceProjectLight', (Restangular) ->
    return Restangular.service('makerscience/projectlight')
)

module.factory('MakerScienceResourceLight', (Restangular) ->
    return Restangular.service('makerscience/resourcelight')
)


module.factory('MakerScienceProjectTaggedItem', (Restangular) ->
    return Restangular.service('makerscience/projecttaggeditem')
)

module.factory('MakerScienceResourceTaggedItem', (Restangular) ->
    return Restangular.service('makerscience/resourcetaggeditem')
)
