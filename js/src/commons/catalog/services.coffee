module = angular.module("commons.catalog.services", ['restangular'])


# Services
module.factory('Project', (Restangular) ->
    return Restangular.service('project/project')
)
module.factory('ProjectNews', (Restangular) ->
    return Restangular.service('project/news')
)

module.factory('ProjectSheet', (Restangular) ->
    return Restangular.service('project/sheet/projectsheet')
)
module.factory('Place', (Restangular) ->
    return Restangular.service('scout/place')
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
