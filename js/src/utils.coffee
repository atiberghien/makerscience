@getObjectIdFromURI = (uri) ->
    splitted_uri = uri.split("/")
    return splitted_uri[splitted_uri.length-1]
        