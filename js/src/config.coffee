debugMode = false

if !debugMode
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://data.makerscience.fr/bucket/upload/',
        loginBaseUrl: 'http://data.makerscience.fr/api/v0',
        oauthBaseUrl: 'http://makerscience.fr',
        media_uri: 'http://data.makerscience.fr',
        rest_uri: "http://data.makerscience.fr/api/v0"
else
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://127.0.0.1:8002/bucket/upload/',
        loginBaseUrl: 'http://127.0.0.1:8002/api/v0',
        oauthBaseUrl: 'http://127.0.0.1:8001',
        media_uri: 'http://127.0.0.1:8002',
        rest_uri: "http://127.0.0.1:8002/api/v0"
