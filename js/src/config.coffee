debugMode = true
prodMode = false

if !debugMode
    @config =
        templateBaseUrl: '/views/',
        useHtml5Mode: true,

        bucket_uri: 'http://data.nonetype.net/bucket/upload/',
        loginBaseUrl: 'http://data.nonetype.net/api/v0',
        oauthBaseUrl: 'http://127.0.0.1:8001',
        media_uri: 'http://data.nonetype.net',
        rest_uri: "http://data.nonetype.net/api/v0"

        facebook :
            clientId : '724284684343376'
        google :
            clientId : '255067193649-5s7fan8nsch2cqft32fka9n36jcd37qg.apps.googleusercontent.com'
            recaptchaKey : "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"

else
    if !prodMode
        @config =
            templateBaseUrl: '/views/',
            useHtml5Mode: true,

            bucket_uri: 'http://makerscience-server.makina-corpus.net/bucket/upload/',
            loginBaseUrl: 'http://makerscience-server.makina-corpus.net/api/v0',
            oauthBaseUrl: 'http://makerscience-server.makina-corpus.net',
            media_uri: 'http://makerscience-server.makina-corpus.net',
            rest_uri: "http://makerscience-server.makina-corpus.net/api/v0"

            facebook :
                clientId : '724284684343376'
            google :
                clientId : '255067193649-5s7fan8nsch2cqft32fka9n36jcd37qg.apps.googleusercontent.com'
                recaptchaKey : "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"

    else
        @config =
            templateBaseUrl: '/views/',
            useHtml5Mode: true,

            bucket_uri: 'http://chez.moi.com:8002/bucket/upload/',
            loginBaseUrl: 'http://chez.moi.com:8002/api/v0',
            oauthBaseUrl: 'http://chez.moi.com:8001',
            media_uri: 'http://chez.moi.com:8002',
            rest_uri: "http://chez.moi.com:8002/api/v0"

            facebook :
                clientId : '724284684343376'
            google :
                clientId : '255067193649-5s7fan8nsch2cqft32fka9n36jcd37qg.apps.googleusercontent.com'
                recaptchaKey : "6LfrjQwTAAAAADL047Yx9IUOgsFAfHpjq8InqwMF"
