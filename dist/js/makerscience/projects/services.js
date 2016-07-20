(function() {
  var module;

  module = angular.module("makerscience.projects.services", ['restangular']);

  module.factory("ProjectService", function(ProjectSheetTemplate, ProjectSheet, Project, ProjectSheetQuestionAnswer, PostalAddress, BucketRestangular) {
    return {
      fetchCoverURL: function(coverId) {
        if (coverId) {
          return config.media_uri + '/bucket/file/' + coverId + '/thumbnail/?dim=710x390&border=true';
        }
        return "/img/default_project.jpg";
      },
      updateProjectSheet: function(resources, projectsheet) {
        var putData;
        putData = {};
        putData[resources.fieldName] = resources.data;
        switch (resources.resourceName) {
          case 'Project':
            return Project.one(resources.resourceId).patch(putData).then(function(projectResult) {
              projectsheet.parent.website = projectResult.website;
              return false;
            });
          case 'ProjectSheetQuestionAnswer':
            return ProjectSheetQuestionAnswer.one(resources.resourceId).patch(putData);
          case 'ProjectSheet':
            return ProjectSheet.one(resources.resourceId).patch(putData);
          case 'PostalAddress':
            return PostalAddress.one(resources.resourceId).patch(putData);
        }
      },
      uploadMedia: function(media, bucketId, projectId) {
        console.log(media);
        return new Promise(function(resolve, reject) {
          var formData;
          formData = new FormData();
          formData.append('bucket', bucketId);
          formData.append('title', media.title);
          formData.append('type', media.type);
          if (media.file) {
            formData.append('file', media.file);
          }
          if (media.url) {
            formData.append('url', media.url);
          }
          if (media.type === 'video') {
            formData.append('video_id', media.videoId);
            formData.append('video_provider', media.videoProvider);
          }
          if (media.description) {
            formData.append('description', media.description);
          }
          if (media.author) {
            formData.append('is_author', media.is_author);
            formData.append('author', media.author);
          }
          if (media.experience) {
            formData.append('experience_detail', JSON.stringify(media.experience));
          }
          return BucketRestangular.all(projectId).withHttpConfig({
            transformRequest: angular.identity
          }).customPOST(formData, void 0, void 0, {
            'Content-Type': void 0
          }).then(function(res) {
            return resolve(res);
          })["catch"](function(err) {
            return reject(err);
          });
        });
      }
    };
  });

}).call(this);
