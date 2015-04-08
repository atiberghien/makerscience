module = angular.module("makerscience.base.services", ['restangular'])

class DataSharing
        constructor: (@$rootScope) ->
                console.log("init DataSharing")
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
