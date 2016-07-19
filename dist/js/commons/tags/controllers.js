(function() {
  var module;

  module = angular.module("commons.tags.controllers", []);

  module.controller("TagListCtrl", function($scope, Tag) {
    return $scope.tags = Tag.getList().$object;
  });

  module.controller("TagAutoCompleteCtrl", function($scope, Tag) {
    return $scope.loadTags = function(query) {
      return Tag.getList().then(function(tagResults) {
        var availableTags;
        availableTags = [];
        angular.forEach(tagResults, function(tag) {
          var tmpTag;
          if (tag.name.indexOf(query) > -1) {
            tmpTag = {
              'text': tag.name,
              'weight': tag.weight
            };
            return availableTags.push(tmpTag);
          }
        });
        return availableTags;
      });
    };
  });

  module.controller('TagPopupCtrl', function($scope, $modalInstance, params) {
    $scope.preparedTags = params.preparedTags;
    $scope.editableTag = params.editableTag;
    if ($scope.editableTag) {
      $scope.tagType = params.tagType;
      $scope.addTag = params.addTag;
      $scope.removeTag = params.removeTag;
    }
    $scope.ok = function() {
      return $modalInstance.close();
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('cancel');
    };
  });

}).call(this);
