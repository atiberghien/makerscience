module = angular.module('makerscience.projects.controllers')

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, $timeout, ProjectSheet, FormService, ProjectService, GalleryService,
                             MakerScienceResource,  MakerScienceResourceTaggedItem, ObjectProfileLink) ->


    angular.extend(this, $controller('MakerSciencePostCreateCtrl', {$scope: $scope}))
    $scope.projectsheet = { medias: [] }
    $scope.QAItems = []

    FormService.init('experience-makerscience').then((response) ->
        $scope.QAItems = response.QAItems
        $scope.projectsheet = response.projectsheet
    )

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []
    $scope.medias = []

    $scope.hideControls = false

    $scope.saveMakerscienceResource = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            $scope.hideControls = false
            return false
        else
            console.log("submitting form")

        console.log $scope.projectsheet
        FormService.save($scope.projectsheet).then((resourcesheetResult) ->
            makerscienceResourceData =
                parent : resourcesheetResult.project.resource_uri
                duration : $scope.projectsheet.duration

            MakerScienceResource.post(makerscienceResourceData).then((makerscienceResourceResult)->
                # add connected user as team member of project with detail "porteur"
                ObjectProfileLink.one().customPOST(
                    profile_id: $scope.currentMakerScienceProfile.parent.id,
                    level: 10,
                    detail : "Créateur/Créatrice",
                    isValidated:true
                , 'makerscienceresource/'+makerscienceResourceResult.id)

                angular.forEach($scope.themesTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/th", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.formatsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/fm", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                angular.forEach($scope.targetsTags, (tag)->
                    MakerScienceResourceTaggedItem.one().customPOST({tag : tag.text}, "makerscienceresource/"+makerscienceResourceResult.id+"/tg", {}).then((taggedItemResult) ->
                        ObjectProfileLink.one().customPOST(
                            profile_id: $scope.currentMakerScienceProfile.parent.id,
                            level: 50,
                            detail : '',
                            isValidated:true
                        , 'taggeditem/'+taggedItemResult.id)
                    )
                )

                # if no photos to upload, directly go to new project sheet
                if _.size($scope.medias) == 0
                    $scope.fake_progress = 0
                    ##UGLY : to be sur that all remote ops are finished ... :/
                    for x in [1..5]
                        $scope.fake_progress += 100/5

                    $timeout(() ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
                    ,5000)
                else
                    console.log $scope.medias
                    promises = []

                    angular.forEach($scope.medias, (media, index) ->
                        promise = ProjectService.uploadMedia(media, resourcesheetResult.bucket.id, resourcesheetResult.id)
                        promises.push(promise)
                    )

                    Promise.all(promises).then(() ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
                    ).catch((err) ->
                        console.error err
                    )

            )
        )
)
