## Load modules

_ = require 'lodash'
bodyParser = require 'body-parser'
express = require 'express'
levelup = require 'levelup'
path = require 'path'
uuid = require 'node-uuid'


## Initiate Express app

app = express()
app.enable 'strict routing'


## Initiate LevelDB database

databasePath = path.join __dirname, 'database'  # TODO Change path
database = levelup databasePath


## Serve static files and parse request body

app.use '/static', express.static path.join __dirname, 'static'
app.use bodyParser.json()


## Server main entry point index.html

app.get ['/', '/scan/*', '/list/*'], (request, response) ->
    response.sendFile path.join __dirname, 'static', 'templates', 'index.html'
    return


## Setup router for base path /api

router = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'
app.use '/api', router


## Setup route for /api/object

router.get '/object', (request, response, next) ->
    objects = {}
    database.createReadStream()  # TODO Care about order of retrieved data.
    .on 'data', (chunk) ->
        [type, id, property] = chunk.key.split ':'
        switch type
            when 'object'
                if not objects[id]?
                    objects[id] = {}
                objects[id][property] = chunk.value
                if property is 'personID'
                    objects[id].personDescription = 'Unknown'
            when 'person'
                _.forOwn objects, (object, objectID) ->
                    if object.personID is id
                        object.personDescription = chunk.value
        return
    .on 'error', (err) ->
        next err
        return
    .on 'end', ->
        response.send objects
        return
    return


## Setup route for /api/object/:id

# Catch 'id' parameter
router.use '/object/:id', (request, response, next) ->
    request.objectID = request.params.id
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

# Handle DELETE requests. Delete objects from database.
router.delete '/object/:id', (request, response, next) ->
    operations = []
    operations.push
        type: 'del'
        key: "object:#{request.objectID}:objectDescription"
    operations.push
        type: 'del'
        key: "object:#{request.objectID}:personID"
    database.batch operations, (err) ->
        if err
            next err
        else
            response.send
                details: 'Object successfully deleted.'
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
        objectDescription = fromDatabase.objectDescription or 'Unknown object'
        _.assign response.data,
            object:
                objectID: request.objectID
                objectDescription: objectDescription
        if fromDatabase.personID
            database.get "person:#{fromDatabase.personID}", (err, value) ->
                personDescription = value or 'Unknown'
                if err and not err.notFound
                    next err
                _.assign response.data,
                    person:
                        personID: fromDatabase.personID
                        personDescription: personDescription
                response.send response.data
                return
        else
            response.send response.data
        return
    return


## Setup route for /api/person/:id

# Catch 'id' parameter
router.use '/person/:id', (request, response, next) ->
    request.personID = request.params.id
    response.data = {}
    next()
    return

# Handle PATCH requests. Save data to database.
router.patch '/person/:id', (request, response, next) ->
    if request.body.personDescription
        database.put(
            "person:#{request.personID}"
            request.body.personDescription
            (err) ->
                if err
                    next err
                else
                    response.data.details = 'Data successfully saved.'
                    next()
                return
        )
    else
        response.status 400
        .send
            details: "Person description for person
                      '#{request.personID}' is missing."
    return

# Handle DELETE requests. Delete persons from database.
router.delete '/person/:id', (request, response, next) ->
    database.del "person:#{request.personID}", (err) ->
        if err
            next err
        else
            response.send
                details: 'Person successfully deleted.'
        return
    return

# Handle PATCH and GET requests. Retrieve data from database.
router.all '/person/:id', (request, response, next) ->
    database.get "person:#{request.personID}", (err, value) ->
        personDescription = value or 'Unknown'
        if err and not err.notFound
            next err
        _.assign response.data,
            person:
                personID: request.personID
                personDescription: personDescription
        response.send response.data
        return
    return


## Setup route for /api/supplies/:id

# Catch 'id' parameter
router.use '/supplies/:id', (request, response, next) ->
    request.suppliesID = request.params.id
    response.data = {}
    next()
    return

# Handle PATCH requests. Save data to database.
router.patch '/supplies/:id', (request, response, next) ->
    operations = []
    if request.body.suppliesDescription
        operations.push
            type: 'put'
            key: "supplies:#{request.suppliesID}:suppliesDescription"
            value: request.body.suppliesDescription
    if request.body.personID and typeof request.body.number is 'number' and
            request.body.number > 0
        _.times request.body.number, ->
            itemUUID = uuid.v4()
            operations.push
                type: 'put'
                key: "supplies:#{request.suppliesID}:item:#{itemUUID}"
                value: request.body.personID
    database.batch operations, (err) ->
        if err
            next err
        else
            response.data.details = 'Data successfully saved.'
            next()
        return
    return

# Handle DELETE requests. Delete persons from database.
# TODO

# Handle PATCH and GET requests. Retrieve data from database.
router.all '/supplies/:id', (request, response, next) ->
    fromDatabase =
        suppliesID: request.suppliesID
        suppliesDescription: 'Unknown'
        items: []
    database.createReadStream
        gte: "supplies:#{request.suppliesID}:item:"
        lte: "supplies:#{request.suppliesID}:suppliesDescription"
    .on 'data', (chunk) ->
        keyArray = chunk.key.split ':'
        if keyArray.length is 3
            fromDatabase.suppliesDescription = chunk.value
        else
            [..., itemUUID] = chunk.key.split ':'
            fromDatabase.items.push itemUUID
        return
    .on 'error', (err) ->
        next err
        return
    .on 'end', ->
        response.data.supplies = fromDatabase
        response.send response.data
        return
    return


# Start server
port = 8080
app.listen port, ->
    console.log "Example app listening on http://localhost:#{port}/"
    return
