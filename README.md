Imagination.social HTML FrontEnd
===========

A Projet front-end companion for the Data Server. 

Usage
=====

   sudo aptitude install ruby-compass ruby-fssm coffeescript

   git clone hhttps://github.com/UnissonCo/imagination.social.git
   
   cd js
    
   nano config.js

    config :
        bucket_uri: 'http://data.patapouf.org/bucket/upload/',
        loginBaseUrl: 'http://data.patapouf.org/api/v0',
        oauthBaseUrl: 'http://data.patapouf.org',
        media_uri: 'http://data.patapouf.org',
        rest_uri: "http://data.patapouf.org/api/v0"

   ./coffee_watch.sh
   
   cd ..
   cd ..
   cd css
   
   compass w
   
   cd ..
   
   python -m SimpleHTTPServer 8080
