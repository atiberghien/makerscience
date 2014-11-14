module = angular.module("makerscience.catalog.controllers", ['makerscience.catalog.services', 'commons.graffiti.controllers'])

module.controller("MakerScienceProjectListCtrl", ($scope, MakerScienceProject) ->
    $scope.projects = MakerScienceProject.getList().$object
)

module.controller("MakerScienceResourceListCtrl", ($scope, MakerScienceResource) ->
    $scope.projects = MakerScienceResource.getList().$object
)

module.controller("MakerScienceProjectSheetCreateCtrl", ($scope, $state, $controller, MakerScienceProject) ->
    $controller('ProjectSheetCreateCtrl', {$scope: $scope})
    $scope.tags = []

    $scope.saveMakerscienceProject = (projectsheet) ->
        tagsParam = []
        angular.forEach($scope.tags, (tag) ->
            tagsParam.push(tag.text)
        )
        $scope.saveProject(projectsheet).then((projectsheet) ->
            MakerScienceProject.post({'parent' : projectsheet.project, 'tags' : tagsParam}).then(->
                $state.go("project.detail", {slug : $scope.projectsheet.project.slug})
            )
        )
)

module.controller("MakerScienceProjectSheetCtrl", ($scope, $stateParams, $controller, MakerScienceProject, Tag, TaggedItem) ->
    $controller('ProjectSheetCtrl', {$scope: $scope, $stateParams: $stateParams})

    $scope.init().then( ->
        $scope.projectsheet.tags = []
        MakerScienceProject.one().get({'parent__slug' : $stateParams.slug}).then((makerScienceProjectResult) ->
            project = makerScienceProjectResult.objects[0]
            angular.forEach(project.tags, (tagURI) ->
                tagID = getObjectIdFromURI(tagURI)
                Tag.one(tagID).get().then((tagResult) ->
                    TaggedItem.one().customGET("makerscienceproject/"+project.id+"/"+tagID).then((taggdItemResult) ->
                        $scope.projectsheet.tags.push({text : tagResult.name, taggedItemURI : taggdItemResult.resource_uri})
                    )
                )
            )
            $scope.projectsheet.id = project.id
            $scope.projectsheet.modified = project.modified
        )
    )

    $scope.addTagFromProject = (tag) ->
        TaggedItem.one().customPOST({tag : {name: tag.text}}, "makerscienceproject/"+$scope.projectsheet.id, {})

    $scope.removeTagFromProject = (tag) ->
        taggedItemID = getObjectIdFromURI(tag.taggedItemURI)
        TaggedItem.one(taggedItemID).remove()

)

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, MakerScienceResource) ->

)

module.controller("MakerScienceResourceSheetCtrl", ($scope, $stateParams, $controller, MakerScienceResource, Tag) ->

)
