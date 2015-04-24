# MakerScience FrontEnd

This application is a front-end for the [MakerScience server](github.com/atiberghien/makerscience-server)

## Underlying technologies
* AngularJS (and restangular to deal with server-side REST API)
* Coffescript for scripts
* Compass/Sass for stylesheets
* bower for javascript dependencies
* [grunt](gruntjs.com/getting-started) for project building

## Install

First, you need to install grunt client (`grunt-cli`) globally on your system. It could be install using `npm`.

Then :
* clone the repo : `git clone https://github.com/atiberghien/makerscience.git`
* install grunt dependencies (packages.json): `npm install`
* install application dependencies (bower.json) : `bower install`
* build the project and run HTTP test server : `grunt`
