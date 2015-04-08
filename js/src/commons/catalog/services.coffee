module = angular.module("commons.catalog.services", ['restangular'])


# Services
module.factory('Project', (Restangular) ->
    return Restangular.service('project/project')
)
module.factory('ProjectSheet', (Restangular) ->
    return Restangular.service('project/sheet/projectsheet')
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

module.factory('ProjectProgress', (Restangular) ->
    return Restangular.service('projectprogress')
)

module.factory('BucketFile', (Restangular) ->
    return Restangular.service('bucket/file')
)

module.factory('Bucket', (Restangular) ->
    return Restangular.service('bucket/bucket')
)
