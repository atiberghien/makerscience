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
    return Restangular.service('project/sheet/template')
)

module.factory('ProjectSheetQuestionAnswer', (Restangular) ->
    return Restangular.service('project/sheet/question_answer')
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

# Restangular service without api/v0
module.factory('BareRestangular', (Restangular) ->
    return Restangular.withConfig((RestangularConfigurer) ->
        RestangularConfigurer.setBaseUrl(config.dataserver_url)
    )
)