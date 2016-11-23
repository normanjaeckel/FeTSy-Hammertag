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
            response.status(500).json
                detail: error
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
            response.status(500).json
                detail: error
        else if result.upsertedCount is 1
            response.status(201).json
                details: 'Object successfully created.'
        else
            response.send
                details: 'Object successfully updated.'
        return
    return

# Handle DELETE requests.
.delete '/:id', (request, response) ->
    selector = id: request.objectId
    option = {}
    database.object().removeOne selector, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            response.send
                details: 'Object successfully deleted.'
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
            response.status(500).json
                detail: error
        else
            database.getObject request.objectId, (error, object) ->
                if error?
                    response.status(500).json
                        detail: error
                else if result.upsertedCount is 1
                    response.status(201).send
                        details: 'Object successfully created.'
                        object: object
                else
                    response.send
                        details: 'Object successfully updated.'
                        object: object
                return
        return
    return
