debugMode = false

if !debugMode
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://data.nonetype.net/bucket/upload/',
        loginBaseUrl: 'http://data.nonetype.net/api/v0',
        oauthBaseUrl: 'http://127.0.0.1:8001',
        media_uri: 'http://data.nonetype.net',
        rest_uri: "http://data.nonetype.net/api/v0"
else
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://127.0.0.1:8002/bucket/upload/',
        loginBaseUrl: 'http://127.0.0.1:8002/api/v0',
        oauthBaseUrl: 'http://127.0.0.1:8001',
        media_uri: 'http://127.0.0.1:8002',
        rest_uri: "http://127.0.0.1:8002/api/v0"
