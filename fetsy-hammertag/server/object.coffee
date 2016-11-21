debug = require('debug') 'fetsy-hammertag:server:object'
express = require 'express'

app = require './app'
database = require './database'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


## Detail route

# Catch 'id' parameter
.use '/:id', (request, response, next) ->
    request.objectId = request.params.id
    next()
    return

# Handle GET requests. Retrieve data from database.
.get '/:id', (request, response) ->
    database.getObject request.objectId, (error, object) ->
        if error?
            response.sendStatus 400
        else
            response.send
                object: object
        return
    return

# Handle PATCH requests.
.patch '/:id', (request, response) ->
    filter = id: request.objectId
    update =
        $set:
            description: request.body.description
    options =
        upsert: true
    database.object().updateOne filter, update, options, (error, result) ->
        if error?
            response.sendStatus 400
        else if result.upsertedCount is 1
            response.sendStatus 201
        else
            response.sendStatus 200
        return
    return


## Route to apply new persons

# Handle POST requests.
.post '/:id/person', (request, response) ->
    person =
        id: request.body.id
        timestamp: +new Date() / 1000
    filter = id: request.objectId
    update =
        $push:
            persons: person
    options =
        upsert: true
    database.object().updateOne filter, update, options, (error, result) ->
        if error?
            response.sendStatus 400
        else if result.upsertedCount is 1
            response.status(201).send
                object:
                    id: request.objectId
                    description: 'Unknown object'
                    persons: [
                        person
                    ]
        else
            database.getObject request.objectId, (error, object) ->
                if error?
                    response.sendStatus 400
                else
                    response.send
                        object: object
                return
        return
    return
