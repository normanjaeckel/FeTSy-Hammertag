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


## Setup route for /api/object

router.get '/object', (request, response, next) ->
    objects = {}
    database.createReadStream()
    .on 'data', (chunk) ->
        [type, id, property] = chunk.key.split ':'
        switch type
            when 'object'
                if not objects[id]?
                    objects[id] = {}
                objects[id][property] = chunk.value
            when 'person'
                _.forOwn objects, (value, objectID) ->
                    if value.personID is id
                        value.personDescription = chunk.value
        return
    .on 'error', (err) ->
        next err
        return
    .on 'end', ->
        response.send objects
        return
    return


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
    if request.body.objectDescription
        operations.push
            type: 'put'
            key: "object:#{request.objectID}:objectDescription"
            value: request.body.objectDescription
    if request.body.personID
        operations.push
            type: 'put'
            key: "object:#{request.objectID}:personID"
            value: request.body.personID
        if request.body.personDescription
            operations.push
                type: 'put'
                key: "person:#{request.body.personID}"
                value: request.body.personDescription
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
        gte: "object:#{request.objectID}:objectDescription"
        lte: "object:#{request.objectID}:personID"
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
                objectDescription: fromDatabase.objectDescription or 'Unknown object'
        if fromDatabase.personID
            database.get "person:#{fromDatabase.personID}", (err, personDescription) ->
                if err and not err.notFound
                    next err
                _.assign response.data,
                    person:
                        personID: fromDatabase.personID
                        personDescription: personDescription or 'Unknown'
                response.send response.data
                return
        else
            response.send response.data
        return
    return


# Start server

app.listen 8080, ->
  console.log 'Example app listening on http://localhost:8080/'
  return
