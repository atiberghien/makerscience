module = angular.module("makerscience.projects.services", ['restangular'])

module.factory("ProjectService", (ProjectSheetTemplate, ProjectSheet, Project, ProjectSheetQuestionAnswer, PostalAddress, BucketRestangular) ->
    return {

        fetchCoverURL: (projectsheet) ->
            if projectsheet.cover
                return config.media_uri + projectsheet.cover.thumbnail_url+'?dim=710x390&border=true'
            return "/img/default_project.jpg"

        updateProjectSheet: (resources, projectsheet, fieldName, data) ->
            putData = {}
            putData[fieldName] = resources.data
            switch resources.resourceName
                when 'Project' then Project.one(resources.resourceId).patch(putData).then((projectResult) ->
                    projectsheet.parent.website = projectResult.website
                    return false
                )
                when 'ProjectSheetQuestionAnswer' then ProjectSheetQuestionAnswer.one(resources.resourceId).patch(putData)
                when 'ProjectSheet' then ProjectSheet.one(resources.resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resources.resourceId).patch(putData)

        uploadMedia: (media, bucketId, projectId) ->
            return new Promise((resolve, reject) ->
                formData = new FormData()
                if media.file
                    formData.append('file', media.file)
                if media.url
                    formData.append('url', media.url)
                if media.type == 'video'
                    formData.append('video_id', media.videoId)
                formData.append('bucket', bucketId)
                formData.append('title', media.title)
                formData.append('type', media.type)

                BucketRestangular.all(projectId)
                  .withHttpConfig({transformRequest: angular.identity})
                  .customPOST(formData, undefined, undefined, { 'Content-Type': undefined }).then((res) ->
                        resolve(res)
                    ).catch((err) ->
                        reject(err)
                    )
            )

    }
)
