module = angular.module("makerscience.base.services", ['restangular'])

class DataSharing
        constructor: (@$rootScope) ->
                # console.log("init DataSharing")
                @sharedObject = {}

# Services
module.factory('DataSharing', ($rootScope) ->
    return new DataSharing($rootScope)
)

class FilterService
    constructor: (@$rootScope)->
        console.log("init FilterService")
        @filterParams = {}
            # tags : []
            # query : ''

module.factory('FilterService', ($rootScope) ->
    return new FilterService($rootScope)
)

module.factory('StaticContent', (Restangular) ->
    return Restangular.service('makerscience/static')
)

module.factory('Notification', (Restangular) ->
    return Restangular.service('notification')
)


# Projects / Resources
module.factory('MakerScienceProject', (Restangular) ->
    return Restangular.service('makerscience/project')
)

module.factory('MakerScienceResource', (Restangular) ->
    return Restangular.service('makerscience/resource')
)

module.factory('MakerScienceProjectLight', (Restangular) ->
    return Restangular.service('makerscience/projectlight')
)

module.factory('MakerScienceResourceLight', (Restangular) ->
    return Restangular.service('makerscience/resourcelight')
)

module.factory('MakerScienceProjectTaggedItem', (Restangular) ->
    return Restangular.service('makerscience/projecttaggeditem')
)

module.factory('MakerScienceResourceTaggedItem', (Restangular) ->
    return Restangular.service('makerscience/resourcetaggeditem')
)

module.factory('Project', (Restangular) ->
    return Restangular.service('project/project')
)

module.factory('ProjectNews', (Restangular) ->
    return Restangular.service('project/news')
)

module.factory('ProjectSheet', (Restangular) ->
    return Restangular.service('project/sheet/projectsheet')
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
