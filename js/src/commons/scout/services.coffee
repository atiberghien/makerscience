module = angular.module("commons.scout.services", ['restangular'])

module.factory('PostalAddress', (Restangular) ->
    return Restangular.service('scout/postaladdress')
)
