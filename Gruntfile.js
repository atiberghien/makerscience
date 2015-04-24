module.exports = function(grunt) {
    var path = require('path');
    var bower = require('bower');

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        wiredep: {
            task: {
                directory: 'bower_components',
                src: ['index.html',],
                options : {
                    exclude: [
                        '/bootstrap-css-only/',
                        'bower_components/rangy/rangy-core.min.js',
                        "bower_components/rangy/rangy-cssclassapplier.min.js",
                        "bower_components/rangy/rangy-selectionsaverestore.min.js",
                        "bower_components/rangy/rangy-serializer.min.js",
                        "bower_components/leaflet/dist/leaflet-src.js",
                        "bower_components/geocoder-service/geocoder-service.min.js",
                    ],
                    overrides: {
                        "angularjs-gravatardirective": {
                            "main": "dist/angularjs-gravatardirective.js"
                        },
                        "angular-oauth" : {
                            'main' : ["src/js/googleOauth.js", "src/js/angularOauth.js"]
                        },
                        "ng-tags-input" : {
                            'main' : ["ng-tags-input.js", "ng-tags-input.css", "ng-tags-input.bootstrap.css"]
                        },
                        "leaflet.markercluster" : {
                            'main' : ['dist/leaflet.markercluster.js', "dist/MarkerCluster.css",  "dist/MarkerCluster.Default.css"]
                        }
                      }
                }
            }
        },
        compass: {
            dev: {
                options: {
                    sassDir: 'css/sass',
                    cssDir: 'css',
                    importPath : [
                        "bower_components/bootstrap-sass/assets/stylesheets",
                        "./bower_components/font-awesome"
                    ],
                }
            },
        },
        coffee: {
            dist: {
                expand: true,
                flatten: false,
                cwd: 'js/src',
                src: ['**/*.coffee'],
                dest: 'js',
                ext: '.js'
            }
        },
        watch: {
            css: {
                files: 'css/sass/**/*.scss',
                tasks: ['compass'],
            },
            coffee: {
                files: 'js/src/**/*.coffee',
                tasks: ['coffee']
            }
        },
        connect: {
            server: {
                options: {
                    hostname: '0.0.0.0',
                    port: 8001,
                    keepalive: true,
                    debug:true
                }
            }
        },
        concurrent: {
            run: ['watch', 'connect'],
            options: {
                logConcurrentOutput: true
            }
        }
    });

    grunt.loadNpmTasks('grunt-wiredep');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-concurrent');

    grunt.registerTask('default', ['compass:dev', 'coffee', 'concurrent:run']);
};
//
// "exportsOverride" : {
//       "*": {
//         "sass" : "**/*.scss",
//         "js": "**/*.js",
//         "css": "**/*.css",
//         "fonts" : "**/fonts/*"
//       }
//   }
