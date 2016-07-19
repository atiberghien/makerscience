(function() {
  var module;

  module = angular.module("commons.tags.services", ['restangular']);

  module.factory('Tag', function(Restangular) {
    return Restangular.service('tag');
  });

  module.factory('TaggedItem', function(Restangular) {
    return Restangular.service('taggeditem');
  });

  module.factory("TaggedItemService", function($modal, TaggedItem) {
    var TaggedItemService;
    TaggedItemService = {};
    TaggedItemService.openTagPopup = function(preparedTags, tagType, editableTag, addTagCallback, removeTagCallback) {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: '/views/block/modal_tags.html',
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
    return TaggedItemService;
  });

}).call(this);
