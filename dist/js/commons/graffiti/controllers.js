(function() {
  var module;

  module = angular.module("commons.graffiti.controllers", ['commons.graffiti.services']);

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

  module.controller("TaggedItemCtrl", function($scope, $stateParams, $modal, TaggedItem) {
    return $scope.openTagPopup = function(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: '/views/catalog/block/modal_tags.html',
        controller: 'TagPopupCtrl',
        size: 'lg',
        resolve: {
          params: function() {
            return {
              preparedTags: preparedTags,
              tagType: tagType,
              editableTag: editableTag,
              addTag: addTagCallback,
              removeTag: removeTagCallback
            };
          }
        }
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
