express = require 'express'
path = require 'path'


## Load app

app = require './app'


## Setup router for base path /api

# Setup base router
router = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'

# Bind router to /api path
app.use '/api', router

# Add our routes
router.use '/object', require './object'
#router.use '/supplies', require './supplies'

# Add fallback so that we do not run into index.html, see below
router.all '*', (request, response) ->
    response.sendStatus 404


## Serve static files for /static

webclientStaticDirectory = path.join __dirname, '..', 'static'
app.use '/static', express.static(webclientStaticDirectory,
    fallthrough: false
)


## Server main entry point index.html as fallback for all paths except /api
## and /static

app.get '*', (request, response) ->
    response.sendFile path.join(
        webclientStaticDirectory
        'templates'
        'index.html'
    )
    return


## Start server

port = 8080
app.listen port, ->
    console.log "Example app listening on http://localhost:#{port}/"
    return
