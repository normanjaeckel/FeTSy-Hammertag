argv = require 'yargs'
    .argv
cleanCSS = require 'gulp-clean-css'
gulp = require 'gulp'
gulpif = require 'gulp-if'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
jshint = require 'gulp-jshint'
mainBowerFiles = require 'main-bower-files'
nodemon = require 'gulp-nodemon'
path = require 'path'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'


# Helpers and config

productionMode = argv.production

outputDirectory = path.join __dirname, 'dist'

webclientStaticDirectory = path.join outputDirectory, 'static'


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

gulp.task 'coffee', ->
    gulp.src path.join 'fetsy-hammertag', 'scripts', '**', '*.coffee'
    .pipe coffee()
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


# CSS and font files.

gulp.task 'css-all', ['css', 'css-libs', 'fonts-libs'], ->

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


#  Gulp default task.

gulp.task 'default', ['express', 'html', 'js-all', 'css-all'], ->


# Helper tasks.

gulp.task 'jshint', ->
    gulp.src path.join 'fetsy-hammertag', 'scripts', '*.js'
    .pipe jshint()
    .pipe jshint.reporter 'default'

gulp.task 'coffeelint', ->
    gulp.src [
        'gulpfile.coffee'
        path.join 'fetsy-hammertag', 'server', '**', '*.coffee'
        path.join 'fetsy-hammertag', 'scripts', '**', '*.coffee'
    ]
    .pipe coffeelint
        indentation:
            value: 4
    .pipe coffeelint.reporter 'default'

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

gulp.task 'serve', ->
    if productionMode
        nodeEnv = 'production'
        debug = ''
    else
        nodeEnv = 'development'
        debug = 'express:*'
    nodemon
        script: path.join outputDirectory, 'server', 'server.js'
        env:
            DEBUG: debug
            NODE_ENV: nodeEnv
