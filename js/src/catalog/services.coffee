module = angular.module("projectsheet.services", ['restangular'])


# Services
module.factory('Project', (Restangular) ->
    return Restangular.service('project')
)
module.factory('ProjectSheet', (Restangular) ->
    return Restangular.service('projectsheet')
)
module.factory('PostalAddress', (Restangular) ->
    return Restangular.service('scout/postaladdress')
)

module.factory('ProjectSheetTemplate', (Restangular) ->
    return Restangular.service('projectsheettemplate')
)

module.factory('ProjectSheetItem', (Restangular) ->
    return Restangular.service('projectsheetsuggesteditem')
)