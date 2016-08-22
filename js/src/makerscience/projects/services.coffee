module = angular.module("makerscience.projects.services", ['restangular'])

module.factory("ProjectService", (ProjectSheetTemplate, ProjectSheet, Project, ProjectSheetQuestionAnswer, PostalAddress, BucketRestangular) ->
    return {

        fetchCoverURL: (cover) ->
            if cover
                if cover.url
                    return cover.url
                return config.media_uri + '/bucket/file/' + cover.id + '/thumbnail/?dim=710x390&border=true'
            return "/img/default_project.jpg"

        updateProjectSheet: (resources, projectsheet) ->
            putData = {}
            putData[resources.fieldName] = resources.data
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

                # Base
                formData.append('bucket', bucketId)
                formData.append('title', media.title)
                formData.append('type', media.type)

                if media.file
                    formData.append('file', media.file)
                if media.url
                    formData.append('url', media.url)

                # Project
                if media.type == 'video'
                    formData.append('video_id', media.video_id)
                    formData.append('video_provider', media.video_provider)

                # Experience
                if media.description
                    formData.append('description', media.description)
                if media.author
                    formData.append('is_author', media.is_author)
                    formData.append('author', media.author)
                if media.experience
                    formData.append('experience_detail', JSON.stringify(media.experience))
                if media.review
                  formData.append('review', media.review)

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
