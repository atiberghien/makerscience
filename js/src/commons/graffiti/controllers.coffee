module = angular.module("commons.graffiti.controllers", ['commons.graffiti.services'])

module.controller("TagListCtrl", ($scope, Tag) ->
    $scope.tags = Tag.getList().$object
)

module.controller("TagAutoCompleteCtrl", ($scope, $q, Tag) ->
    tags = Tag.getList()

    $scope.loadTags = (query) ->
        deferred = $q.defer()
        availableTags = []
        angular.forEach(tags.$object, (tag) ->
            if tag.name.indexOf(query) > -1
                tmpTag =
                    'text' : tag.name
                availableTags.push(tmpTag)
        )
        deferred.resolve(availableTags)
        return deferred.promise
)
