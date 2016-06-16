module = angular.module('makerscience.projects.controllers')

module.controller("MakerScienceResourceSheetCreateCtrl", ($scope, $state, $controller, $timeout, ProjectSheet, FormService, @$http, FileUploader,
                             MakerScienceResource,  MakerScienceResourceTaggedItem, ObjectProfileLink) ->

    $scope.themesTags = []
    $scope.targetsTags = []
    $scope.formatsTags = []

    $scope.hideControls = false

    $scope.projectsheet =
        videos : {}
    $scope.QAItems = []

    FormService.init('experience-makerscience').then((response) ->
        $scope.QAItems = response.QAItems
        $scope.projectsheet = response.projectsheet
    )

    $scope.uploader = uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )

    $scope.saveMakerscienceResource = (formIsValid) ->
        if !formIsValid
            console.log(" Form invalid !")
            $scope.hideControls = false
            return false
        else
            console.log("submitting form")

        FormService.save().then((resourcesheetResult) ->
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


                ProjectSheet.one(resourcesheetResult.id).patch({videos:$scope.projectsheet.videos})
                # if no photos to upload, directly go to new project sheet
                if $scope.uploader.queue.length == 0
                    $scope.fake_progress = 0
                    ##UGLY : to be sur that all remote ops are finished ... :/
                    for x in [1..5]
                        $scope.fake_progress += 100/5

                    $timeout(() ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})
                    ,5000)
                else
                    $scope.uploader.onBeforeUploadItem = (item) ->
                        item.formData.push(
                            bucket : resourcesheetResult.bucket.id
                        )
                        item.headers =
                           Authorization : $scope.uploader.headers["Authorization"]

                    $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
                        if $scope.uploader.getIndexOfItem(fileItem) == $scope.coverIndex
                            ProjectSheet.one(resourcesheetResult.id).patch({cover:response.resource_uri})

                    $scope.uploader.onCompleteAll = () ->
                        $state.go("resource.detail", {slug : makerscienceResourceResult.parent.slug})

                    $scope.uploader.uploadAll()
            )
        )
)
