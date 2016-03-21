gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
jshint = require 'gulp-jshint'
mainBowerFiles = require 'main-bower-files'
nodemon = require 'gulp-nodemon'
rename = require 'gulp-rename'
path = require 'path'


# Helpers and config

output_directory = path.join 'dist'

specialJSFilter = (exclude) ->
    (file) ->
        name = path.basename file
        if exclude
            name isnt 'html5shiv.js' and
            name isnt 'respond.src.js' and
            '.js' is path.extname name
        else
            name is 'html5shiv.js' or name is 'respond.src.js'


# Express server

gulp.task 'express', ->
    gulp.src path.join 'fetsy-hammertag', 'server.coffee'
    .pipe coffee()
    .pipe gulp.dest path.join output_directory


# HTML files.

gulp.task 'html', ->
    gulp.src path.join 'fetsy-hammertag', 'templates', '*.html'
    .pipe gulp.dest path.join output_directory


# JavaScript files.

gulp.task 'js-all', ['coffee', 'js-special', 'js-libs', 'js-libs-special'], ->

gulp.task 'coffee', ->
    gulp.src path.join 'fetsy-hammertag', 'scripts', '*.coffee'
    .pipe coffee()
    .pipe concat 'fetsy-hammertag.js'
    # Maybe uglify it.
    .pipe gulp.dest path.join output_directory, 'js'

gulp.task 'js-special', ->
    gulp.src path.join 'fetsy-hammertag',
        'scripts'
        'ie10-viewport-bug-workaround.js'
    .pipe gulp.dest path.join output_directory, 'js'

gulp.task 'js-libs', ->
    gulp.src mainBowerFiles
        filter: specialJSFilter true
    .pipe concat 'fetsy-hammertag-libs.js'
    # Maybe uglify it.
    .pipe gulp.dest path.join output_directory, 'js'

gulp.task 'js-libs-special', ->
    gulp.src mainBowerFiles
        filter: specialJSFilter false
    .pipe gulp.dest path.join output_directory, 'js'


# CSS files.

gulp.task 'css-all', ['css', 'css-libs', 'fonts-libs'], ->

gulp.task 'css', ->
    gulp.src path.join 'fetsy-hammertag', 'styles', '*.css'
    .pipe concat 'fetsy-hammertag.css'
    # Maybe uglify it.
    .pipe gulp.dest path.join output_directory, 'css'

gulp.task 'css-libs', ->
    gulp.src mainBowerFiles
        filter: /\.css$/
    .pipe concat 'fetsy-hammertag-libs.css'
    # Maybe uglify it.
    .pipe gulp.dest path.join output_directory, 'css'

gulp.task 'fonts-libs', ->
    gulp.src mainBowerFiles
        filter: /\.(eot)|(svg)|(ttf)|(woff)|(woff2)$/

    .pipe gulp.dest path.join output_directory, 'fonts'


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
        path.join 'fetsy-hammertag', 'scripts', '*.coffee'
    ]
    .pipe coffeelint
        indentation:
            value: 4
    .pipe coffeelint.reporter 'default'

gulp.task 'hint', ['jshint', 'coffeelint'], ->

gulp.task 'watch', ->
    gulp.watch path.join('fetsy-hammertag', 'server.coffee'), ['express']
    gulp.watch path.join('fetsy-hammertag', 'templates', '*.html'), ['html']
    gulp.watch path.join('fetsy-hammertag', 'scripts', '*.coffee'), ['coffee']
    gulp.watch path.join('fetsy-hammertag', 'styles', '*.css'), ['css']
    return

gulp.task 'serve', ->
    nodemon
        script: path.join output_directory, 'server.js'
        env:
            DEBUG: 'express:*'  # TODO Add production flag, add NODE_ENV production variable
