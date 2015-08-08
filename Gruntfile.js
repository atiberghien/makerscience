module.exports = function(grunt) {
    var path = require('path');
    var rewrite = require( "connect-modrewrite" );

    var appConfig = {
        app: require('./bower.json').appPath || 'app',
        dist: 'dist'
    };
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        wiredep: {
            task: {
                directory: 'bower_components',
                src: ['index.html'],
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
                        },
                        "bootstrap-sass" : {
                            'main' : ['assets/javascripts/bootstrap.js',
                                      'assets/javascripts/bootstrap/affix.js',
                                      'assets/javascripts/bootstrap/modal.js',
                                      'assets/javascripts/bootstrap/dropdown.js',
                                      'assets/javascripts/bootstrap/collapse.js']
                        },
                        "angular-ui-utils" : {
                            'main' : ["unique.js",]
                        },
                        "moment" : {
                            'main' : ['moment.js', 'locale/fr.js']
                        },
                        "angular-socialshare" : {
                            'main' : ['angular-socialshare.min.js']
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
                        "bower_components/font-awesome"
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
                    hostname: '127.0.0.1',
                    port: 8001,
                    keepalive: true,
                    debug:true,
                    middleware: function ( connect, options, middlewares ) {
                        var rules = [
                            "!\\.html|\\.js|\\.css|\\.svg|\\.jp(e?)g|\\.png|\\.gif|\\.ttf|\\.otf|\\.eot|\\.woff|\\.woff2$ /index.html"
                        ];
                        middlewares.unshift( rewrite( rules ) );
                        return middlewares;
                    }
                },
            }
        },
        concurrent: {
            run: ['watch', 'connect'],
            options: {
                logConcurrentOutput: true
            }
        },
        copy: {
            dist: {
                files: [
                  {expand: true, src: ['*.html'], dest: 'dist/'},
                  {expand: true, src: ['bower_components/**'], dest: 'dist/'},
                  {expand: true, src: ['css/*.css'], dest: 'dist/'},
                  {expand: true, src: ['img/**'], dest: 'dist/'},
                  {expand: true, src: ['fonts/**'], dest: 'dist/'},
                  {expand: true, src: ['views/**'], dest: 'dist/'},
                  {expand: true, src: ['js/**/*.js'], dest: 'dist/'},
                  {expand: true, cwd: "js/", src: ['config_stating.js'], dest: 'dist/js/', rename: function(dest, src) {
                      return dest + src.replace('_stating','');
                  }},
                ],
          },
        },
        clean: {
          dist: ["dist/"],
          config: ["dist/js/config_stating.js"]
        },
    });

    grunt.loadNpmTasks('grunt-wiredep');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');

    grunt.registerTask('default', ['compass:dev', 'wiredep', 'coffee', 'concurrent:run']);
    grunt.registerTask('dist', ['clean:dist', 'copy:dist', 'clean:config']);
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
