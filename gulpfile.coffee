argv = require 'yargs'
    .argv
b2v = require 'buffer-to-vinyl'
cleanCSS = require 'gulp-clean-css'
fs = require 'fs'
gulp = require 'gulp'
gulpif = require 'gulp-if'
gulpNgConfig = require 'gulp-ng-config'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
jshint = require 'gulp-jshint'
mainBowerFiles = require 'main-bower-files'
merge = require 'merge-stream'
nodemon = require 'gulp-nodemon'
path = require 'path'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
yaml = require 'js-yaml'
_ = require 'lodash'


# Helpers and config

productionMode = argv.production

outputDirectory = path.join __dirname, 'dist'

webclientStaticDirectory = path.join outputDirectory, 'static'

clientConfig =
    logoURL: ''


# Express server

gulp.task 'express', ->
    gulp.src path.join 'fetsy-hammertag', 'server', '**', '*.coffee'
    .pipe coffee()
    .pipe gulp.dest path.join outputDirectory, 'server'


# HTML files.

gulp.task 'html', ->
    gulp.src path.join 'fetsy-hammertag', 'templates', '*.html'
    .pipe gulp.dest path.join webclientStaticDirectory, 'templates'


# JavaScript files.

gulp.task 'js-all', ['coffee', 'js', 'js-libs'], ->

gulp.task 'clientConfig', (callback) ->
    fs.readFile 'config.yml', (err, data) ->
        if err
            gutil.log(
                'Could not find or open custom'
                gutil.colors.cyan 'config.yml'
            )
        else
            userClientConfig = yaml.safeLoad data
            _.assign clientConfig, userClientConfig
        callback()

gulp.task 'coffee', ['clientConfig'], ->
    scripts = gulp.src path.join 'fetsy-hammertag', 'scripts', '**', '*.coffee'
    .pipe coffee()

    config = b2v.stream new Buffer(JSON.stringify(clientConfig)), 'config.json'
    .pipe gulpNgConfig 'FeTSy-Hammertag.config',
        wrap: true

    merge scripts, config
    .pipe concat 'fetsy-hammertag.js'
    .pipe gulpif productionMode, uglify()
    .pipe gulp.dest path.join webclientStaticDirectory, 'js'

gulp.task 'js', ->
    gulp.src path.join 'fetsy-hammertag', 'scripts', '*.js'
    .pipe gulpif productionMode, uglify()
    .pipe gulp.dest path.join webclientStaticDirectory, 'js'

gulp.task 'js-libs', ->
    isntSpecialFile = (file) ->
        name = path.basename file.path
        name isnt 'html5shiv.js' and name isnt 'respond.src.js'
    gulp.src mainBowerFiles
        filter: /\.js$/
    .pipe gulpif isntSpecialFile, concat 'fetsy-hammertag-libs.js'
    .pipe gulpif productionMode, uglify()
    .pipe gulp.dest path.join webclientStaticDirectory, 'js'


# CSS, font and favicon files.

gulp.task 'css-all', ['css', 'css-libs', 'fonts-libs', 'favicon'], ->

gulp.task 'css', ->
    gulp.src path.join 'fetsy-hammertag', 'styles', '*.css'
    .pipe concat 'fetsy-hammertag.css'
    .pipe gulpif productionMode, cleanCSS
        compatibility: 'ie8'
    .pipe gulp.dest path.join webclientStaticDirectory, 'css'

gulp.task 'css-libs', ->
    gulp.src mainBowerFiles
        filter: /\.css$/
    .pipe concat 'fetsy-hammertag-libs.css'
    .pipe gulpif productionMode, cleanCSS
        compatibility: 'ie8'
    .pipe gulp.dest path.join webclientStaticDirectory, 'css'

gulp.task 'fonts-libs', ->
    gulp.src mainBowerFiles
        filter: /\.(eot)|(svg)|(ttf)|(woff)|(woff2)$/
    .pipe gulp.dest path.join webclientStaticDirectory, 'fonts'

gulp.task 'favicon', ->
    gulp.src path.join 'fetsy-hammertag', 'favicon.ico'
    .pipe gulp.dest webclientStaticDirectory


#  Gulp default task.

gulp.task 'default', ['express', 'html', 'js-all', 'css-all'], ->


# Helper tasks.

gulp.task 'jshint', ->
    gulp.src path.join 'fetsy-hammertag', 'scripts', '*.js'
    .pipe jshint()
    .pipe jshint.reporter 'default'
    .pipe jshint.reporter 'fail'

gulp.task 'coffeelint', ->
    gulp.src [
        'gulpfile.coffee'
        path.join 'fetsy-hammertag', 'server', '**', '*.coffee'
        path.join 'fetsy-hammertag', 'scripts', '**', '*.coffee'
        path.join 'tests', '**', '*.coffee'
    ]
    .pipe coffeelint
        indentation:
            value: 4
    .pipe coffeelint.reporter 'default'
    .pipe coffeelint.reporter 'fail'

gulp.task 'hint', ['jshint', 'coffeelint'], ->

gulp.task 'watch', [
    'express'
    'html'
    'coffee'
    'css'
], ->
    gulp.watch path.join('fetsy-hammertag', 'server', '**', '*.coffee'),
        ['express']
    gulp.watch path.join('fetsy-hammertag', 'templates', '*.html'),
        ['html']
    gulp.watch path.join('fetsy-hammertag', 'scripts', '**', '*.coffee'),
        ['coffee']
    gulp.watch path.join('fetsy-hammertag', 'styles', '*.css'),
        ['css']
    return

gulp.task 'serve', (callback) ->
    if productionMode
        gutil.log 'Attention: Do not use gulp serve in production mode.'
        gutil.log(
            'Try'
            gutil.colors.cyan "NODE_ENV='production' DEBUG='' FETSY_PORT=8080
                node #{path.join outputDirectory, 'server', 'server.js'}"
            'instead.'
        )
        callback()
    else
        nodemon
            script: path.join outputDirectory, 'server', 'server.js'
            env:
                DEBUG: 'express:*,fetsy-hammertag:*'
                NODE_ENV: 'development'
                FETSY_PORT: 8080
        .on 'end', callback
