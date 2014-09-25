module = angular.module("projectsheet.services", ['restangular'])


# Services
module.factory('Project', (Restangular) ->
        return Restangular.service('project')
)
module.factory('ProjectSheet', (Restangular) ->
        return Restangular.service('projectsheet')
)
