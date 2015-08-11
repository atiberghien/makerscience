module = angular.module("makerscience.catalog.controllers.generic", ['makerscience.catalog.services', 'makerscience.base.services',
                                                                    'makerscience.catalog.controllers.project', 'makerscience.catalog.controllers.resource',
                                                                    'makerscience.base.controllers'])


module.controller('MakerScienceLinkedResourceCtrl', ($scope, MakerScienceResource) ->

    $scope.allAvailableResources = []
    $scope.linkedResources = []

    MakerScienceResource.getList().then((resourceResults)->
        angular.forEach(resourceResults, (resource) ->
            $scope.allAvailableResources.push(
                fullObject: resource
                title : resource.parent.title
            )
        )
    )

    $scope.delLinkedResource = (resource) ->
        resourceIndex = $scope.linkedResources.indexOf(resource)
        $scope.linkedResources.pop(resourceIndex)

    $scope.addLinkedResource = (newLinkedResource) ->
        resource = newLinkedResource.originalObject.fullObject
        if newLinkedResource && $scope.linkedResources.indexOf(resource) < 0
            $scope.linkedResources.push(resource)
            $scope.newLinkedResource = null
            $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea')
)
