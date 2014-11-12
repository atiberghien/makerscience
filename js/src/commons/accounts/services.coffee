module = angular.module("commons.accounts.services", ['restangular'])


# Services
module.factory('Profile', (Restangular) ->
    return Restangular.service('account/profile')
)
