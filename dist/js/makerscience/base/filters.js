(function() {
  var module;

  module = angular.module("makerscience.base.filters", []);

  module.filter('getSummary', function() {
    return function(htmlText) {
      var maxLength, text, tmp;
      maxLength = 100;
      tmp = document.createElement('DIV');
      tmp.innerHTML = htmlText;
      text = tmp.textContent || tmp.innerText || '';
      if (text.length > maxLength) {
        text = text.substr(0, maxLength);
        text = text.substr(0, Math.min(text.length, text.lastIndexOf(" "))) + '...';
      }
      return text;
    };
  });

}).call(this);
