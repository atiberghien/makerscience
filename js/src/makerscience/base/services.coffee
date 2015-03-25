module = angular.module("makerscience.base.services", ['restangular'])

class DataSharing
        constructor: (@$rootScope) ->
                console.log("init DataSharing")
                @sharedObject = {}

# Services
module.factory('DataSharing', ($rootScope) ->
    return new DataSharing($rootScope)
)
