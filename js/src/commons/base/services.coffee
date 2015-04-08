module = angular.module("commons.base.services", ['restangular'])

class DataSharing
        constructor: (@$rootScope) ->
                console.log("init DataSharing")
                @sharedObject = {}

module.factory('DataSharing', ($rootScope) ->
    return new DataSharing($rootScope)
)

class FilterService
    constructor: (@$rootScope)->
        console.log("init FilterService")
        @filterParams = {}

module.factory('FilterService', ($rootScope) ->
    return new FilterService($rootScope)
)

