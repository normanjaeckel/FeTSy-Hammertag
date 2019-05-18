debug = require('debug') 'fetsy-hammertag:server'
exec = require('child_process').exec
express = require 'express'
path = require 'path'


## Load app and database

app = require './app'
database = require './database'
permission = require './permission'
FeTSyError = require './error'


## Setup router for base path /api

# Setup base router
router = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'

# Bind router to /api path
app.use '/api', router

# Add our routes
router.use '/object', require './object'
router.use '/person', require './person'
router.use '/supplies', require './supplies'
router.use '/drop-database', require './dropDatabase'

# Add error handlung for custom exceptions (like 403 permission denied)
router.use (error, request, response, next) ->
    if error instanceof FeTSyError
        response.status error.status
        .json
            detail: error.message
    else
        next()
    return

# Add single configuration endpoint
router.get '/config', (request, response) ->
    welcomeText = 'Welcome to FeTSy-Hammertag'
    fullWritePermissionGranted = permission.fullWritePermissionGranted(
        request.get 'Auth-User'
    )
    if fullWritePermissionGranted
        userName = request.get('Auth-User') or 'Admin'
    else
        userName = request.get('Auth-User') or 'Supporter'
    response.json
        header: process.env.FETSY_HEADER or 'FeTSy-Hammertag'
        welcomeText: process.env.FETSY_WELCOMETEXT or welcomeText
        fullWritePermissionGranted: fullWritePermissionGranted
        userName: userName
    return

# Add fallback so that we do not run into index.html, see below
router.all '*', (request, response) ->
    response.sendStatus 404
    return


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


## Retrieve admin usernames or set permission level

if process.env.FETSY_ADMIN?
    app.set 'admins', process.env.FETSY_ADMIN.split(':')
else
    app.enable 'full write permission granted'


## Connect to database and start server

hostname = undefined
port = process.env.FETSY_PORT or 8080
mongoDBPort = process.env.MONGODB_PORT or 27017
mongoDBDatabase = process.env.MONGODB_DATABASE or 'fetsy-hammertag'
database.connect(mongoDBPort, mongoDBDatabase)
.then ->
    app.listen port, hostname, ->
        url = "http://#{hostname or 'localhost'}:#{port}/"
        debug "FeTSy-Hammertag listening on #{url}"
        if process.env.NOTIFY_SOCKET?
            pythonSkript =
              'python -c "import systemd.daemon, time; ' +
              'systemd.daemon.notify(\'READY=1\'); time.sleep(5)"'
            exec pythonSkript
        return
    return
