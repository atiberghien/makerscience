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

        facebook :
            clientId : '724284684343376'
        google :
            clientId : '192384401460-ntng78ie8hs2to1t1e0i9foi63rss5gr.apps.googleusercontent.com'
            recaptchaKey : "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"

else
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://127.0.0.1:8002/bucket/upload/',
        loginBaseUrl: 'http://127.0.0.1:8002/api/v0',
        oauthBaseUrl: 'http://127.0.0.1:8001',
        media_uri: 'http://127.0.0.1:8002',
        rest_uri: "http://127.0.0.1:8002/api/v0"

        facebook :
            clientId : '724284684343376'
        google :
            clientId : '192384401460-ntng78ie8hs2to1t1e0i9foi63rss5gr.apps.googleusercontent.com'
            recaptchaKey : "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"
