module = angular.module("projectsheet.services", ['restangular'])


# Services
module.factory('ProjectSheet', (Restangular) ->
        return Restangular.service('project/')
)
