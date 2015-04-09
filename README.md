Project platform HTML FrontEnd
===========

A Projet front-end companion for the Data Server. 

Installation
=====

   sudo aptitude install ruby-compass ruby-fssm coffeescript

   git clone https://github.com/UnissonCo/projects-front-end.git
   
   cd js/src
    
   nano config.coffee

#### If using data.patapouf.org as a dataserver, use this configuration (default configuration) : 
   
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
   
   npm install
   
   node_modules/.bin/bower install

   python -m SimpleHTTPServer 8080
