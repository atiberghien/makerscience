module = angular.module("makerscience.base.services", ['restangular'])

class DataSharing
        constructor: (@$rootScope) ->
                @sharedObject = {}

# Services
module.factory('DataSharing', ($rootScope) ->
    return new DataSharing($rootScope)
)
