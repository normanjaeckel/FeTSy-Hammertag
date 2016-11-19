## Load modules

bodyParser = require 'body-parser'
express = require 'express'
path = require 'path'


## Initiate Express app

app = express()
app.enable 'strict routing'


## Load routes and handle app object to them

objectRouter = require('./object')
    app: app


## Serve static files and parse request body

webclientStaticDirectory = path.join __dirname, '..', 'static'
app.use '/static', express.static(webclientStaticDirectory,
    fallthrough: false
)
app.use bodyParser.json()


## Setup router for base path /api

# Setup router
router = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'

# Bind router to /api path
app.use '/api', router

# Add our routes
router.use '/object', objectRouter
#router.use '/supplies', suppliesRouter

# Add fallback so that we do not run into index.html, see below
router.all '*', (request, response) ->
    response.sendStatus 404


## Server main entry point index.html as fallback for all paths except /api

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
