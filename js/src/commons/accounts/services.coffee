module = angular.module("commons.accounts.services", ['restangular'])


module.factory('User', (Restangular) ->
    return Restangular.service('account/user')
)

module.factory('Profile', (Restangular) ->
    return Restangular.service('account/profile')
)

module.factory('ObjectProfileLink', (Restangular) ->
    return Restangular.service('objectprofilelink')
)
