module.exports = function(grunt) {
    var path = require('path');
    var rewrite = require( "connect-modrewrite" );

    var appConfig = {
        app: require('./bower.json').appPath || 'app',
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
                        //"bower_components/leaflet/dist/leaflet-src.js",
                        "bower_components/geocoder-service/geocoder-service.min.js",
                    ],
                    overrides: {
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
                        },
                        "angular-ui-tinymce" : {
                            'main' : ["src/tinymce.js"],
                        },
                        "tinymce-placeholder" : {
                            'main' : ["placeholder/plugin.js"],
                        },
                        "cookieconsent2" : {
                            'main' : ["build/cookieconsent.min.js"],
                        },
                        "font-awesome" : {
                            "main" : ["css/font-awesome.min.css"],
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
            prod: {
                options: {
                    environment: 'production',
                    outputStyle: 'compressed',
                    sassDir: 'css/sass',
                    cssDir: 'css',
                    importPath : [
                        "bower_components/bootstrap-sass/assets/stylesheets",
                        "bower_components/font-awesome"
                    ],
                }
            }
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
                  {expand: true, src: ['makerscience.fr'], dest: 'dist/'},
                  {expand: true, src: ['*.html'], dest: 'dist/'},
                  {expand: true, src: ['favicon.png'], dest: 'dist/'},
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
          dist: ["css/*.css", "dist/"],
        },
        rsync: {
            options: {
                args: ["--verbose"],
                exclude: [".git*","*.scss","node_modules"],
                recursive: true
            },
            staging: {
                options: {
                    src: "./dist/*",
                    dest: "/var/www/makerscience/client",
                    host: "CHANGE_ME",
                    ssh: true,
                    recursive: true,
                    delete: true // Careful this option could cause data loss, read the docs!
                }
            },
            prod: {
                options: {
                    src: "./dist/*",
                    dest: "/home/www/makerscience.fr/client",
                    host: "CHANGE_ME",
                    ssh: true,
                    recursive: true,
                    delete: true // Careful this option could cause data loss, read the docs!
                }
            },
        }
    });

    grunt.loadNpmTasks('grunt-wiredep');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks("grunt-rsync");

    grunt.registerTask('compile', ['compass:prod', 'wiredep', 'coffee']);
    grunt.registerTask('default', ['compass:dev', 'wiredep', 'coffee', 'concurrent:run']);
    grunt.registerTask('dist', ['clean:dist', 'copy:dist']);
    grunt.registerTask('stage', ['compile', 'dist', 'rsync:staging'])
    grunt.registerTask('prod', ["compile", 'dist', 'rsync:prod'])
};
