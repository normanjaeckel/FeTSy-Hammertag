## Load modules

_ = require 'lodash'
bodyParser = require 'body-parser'
express = require 'express'
levelup = require 'levelup'
path = require 'path'


## Initiate Express app

app = express()
app.enable 'strict routing'


## Initiate LevelDB database

databasePath = path.join __dirname, 'database'  # TODO Change path
database = levelup databasePath


## Serve static files and parse request body

app.use express.static __dirname
app.use bodyParser.json()


## Setup router for base path /api

router = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'
app.use '/api', router


## Setup route for /api/object/:id

# Validate 'id' parameter
router.use '/object/:id', (request, response, next) ->
    if isNaN request.params.id
        response.status 400
        .send
            details: "'#{request.params.id}' must be an integer."
    else
        request.objectID = parseInt request.params.id
        response.data = {}
        next()
    return

# Handle PATCH requests. Save data to database.
router.patch '/object/:id', (request, response, next) ->
    operations = []
    for property in [
        'objectDescription'
        'personID'
        'personDescription'
    ]
        if request.body[property]
            operations.push
                type: 'put'
                key: "object:#{request.objectID}:#{property}"
                value: request.body[property]
    database.batch operations, (err) ->
        if err
            next err
        else
            response.data.details = 'Data successfully saved.'
            next()
        return
    return

# Handle PATCH and GET requests. Retrieve data from database.
router.all '/object/:id', (request, response, next) ->
    fromDatabase = {}
    database.createReadStream
        gte: "object:#{request.objectID}:"
        lte: "object:#{request.objectID + 1}:"
    .on 'data', (chunk) ->
        [..., property] = chunk.key.split ':'
        fromDatabase[property] = chunk.value
        return
    .on 'error', (err) ->
        next err
        return
    .on 'end', ->
        _.assign response.data,
            object:
                objectID: request.objectID
                objectDescription: fromDatabase.objectDescription
            person:
                personID: fromDatabase.personID
                personDescription: fromDatabase.personDescription
        response.send response.data
        return
    return


# Start server

app.listen 8080, ->
  console.log 'Example app listening on http://localhost:8080/'
  return
