module = angular.module("makerscience.base.filters", [])

# Filters
module.filter('getSummary', () ->
    return (htmlText) ->
        maxLength = 100

        tmp = document.createElement('DIV')
        tmp.innerHTML = htmlText
        text = tmp.textContent || tmp.innerText || ''

        if text.length > maxLength
            text = text.substr(0, maxLength)
            text = text.substr(0, Math.min(text.length, text.lastIndexOf(" "))) + '...'

        return text;
)
