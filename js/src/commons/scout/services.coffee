module = angular.module("commons.scout.services", ['restangular'])

# module.factory('Place', (Restangular) ->
#     return Restangular.service('scout/place')
# )

module.factory('PostalAddress', (Restangular) ->
    return Restangular.service('scout/postaladdress')
)
