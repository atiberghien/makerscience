(function() {
  var module;

  module = angular.module("makerscience.catalog.controllers.generic", ['makerscience.catalog.services', 'makerscience.base.services', 'makerscience.catalog.controllers.project', 'makerscience.catalog.controllers.resource', 'makerscience.base.controllers']);

  module.controller('MakerScienceLinkedResourceCtrl', function($scope, MakerScienceResource) {
    $scope.allAvailableResources = [];
    $scope.linkedResources = [];
    MakerScienceResource.getList().then(function(resourceResults) {
      return angular.forEach(resourceResults, function(resource) {
        return $scope.allAvailableResources.push({
          fullObject: resource,
          title: resource.parent.title
        });
      });
    });
    $scope.delLinkedResource = function(resource) {
      var resourceIndex;
      resourceIndex = $scope.linkedResources.indexOf(resource);
      return $scope.linkedResources.pop(resourceIndex);
    };
    return $scope.addLinkedResource = function(newLinkedResource) {
      var resource;
      resource = newLinkedResource.originalObject.fullObject;
      if (newLinkedResource && $scope.linkedResources.indexOf(resource) < 0) {
        $scope.linkedResources.push(resource);
        $scope.newLinkedResource = null;
        return $scope.$broadcast('angucomplete-alt:clearInput', 'linked-idea');
      }
    };
  });

}).call(this);
