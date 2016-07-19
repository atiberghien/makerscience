(function() {
  var module;

  module = angular.module("commons.gallery.services", []);

  module.factory("GalleryService", function() {
    var coverId, extensionIsValid, getVideoProvider, initMediaProject, initMediaResource, isTypeDocument, isTypeImage, isUrl, isUrlDocument, isUrlImage, isUrlVideo, setCoverId;
    coverId = null;
    extensionIsValid = function(url, validExtensions) {
      var ext;
      ext = url.split('.').pop();
      return validExtensions.indexOf(ext) > -1;
    };
    initMediaProject = function(type) {
      var media, uniqueId;
      uniqueId = _.uniqueId();
      media = {
        id: uniqueId,
        title: '',
        type: type
      };
      return media;
    };
    initMediaResource = function(type, author) {
      var media, uniqueId;
      uniqueId = _.uniqueId();
      media = {
        id: uniqueId,
        title: '',
        type: type,
        is_author: true,
        author: author
      };
      return media;
    };
    setCoverId = function(id) {
      this.coverId = this.coverId !== null && this.coverId === id ? null : id;
      return this.coverId;
    };
    getVideoProvider = function(url) {
      var dailymotion, youtube, youtube_short;
      youtube = 'youtube.com';
      youtube_short = 'youtu.be';
      dailymotion = 'dai.ly';
      if (url.indexOf(youtube) > -1 || url.indexOf(youtube_short) > -1) {
        return 'youtube';
      } else if (url.indexOf(dailymotion) > -1) {
        return 'dailymotion';
      } else {
        return null;
      }
    };
    isUrlImage = function(url) {
      var extensions;
      extensions = ['png', 'jpg', 'gif'];
      return extensionIsValid(url, extensions);
    };
    isUrlDocument = function(url) {
      var extensions;
      extensions = ['doc', 'docx', 'pdf', 'ppt', 'xls', 'xlc', 'xlr', 'odt', 'odb', 'odc', 'odf', 'odg', 'odp', 'ods', 'odt'];
      return extensionIsValid(url, extensions);
    };
    isUrlVideo = function(url) {
      if (getVideoProvider(url) !== null) {
        return true;
      }
    };
    isUrl = function(url) {
      var pattern;
      pattern = new RegExp(/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/);
      return pattern.test(url);
    };
    isTypeImage = function(type) {
      var types;
      types = ['image/png', 'image/jpeg', 'image/gif'];
      return types.indexOf(type) > -1;
    };
    isTypeDocument = function(type) {
      var types;
      types = ['application/pdf', 'application/vnd.oasis.opendocument.text', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.wordprocessingml.template', 'application/msword', 'application/zip', 'application/x-compressed-zip', 'text/x-markdown', 'text/plain', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'application/vnd.ms-powerpointtd', 'image/png', 'image/jpeg', 'image/gif'];
      return types.indexOf(type) > -1;
    };
    return {
      initMediaProject: initMediaProject,
      initMediaResource: initMediaResource,
      setCoverId: setCoverId,
      getVideoProvider: getVideoProvider,
      isUrlImage: isUrlImage,
      isUrlDocument: isUrlDocument,
      isUrlVideo: isUrlVideo,
      isUrl: isUrl,
      isTypeImage: isTypeImage,
      isTypeDocument: isTypeDocument,
      coverId: this.coverId
    };
  });

}).call(this);
