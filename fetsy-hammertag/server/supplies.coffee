debug = require('debug') 'fetsy-hammertag:server:supplies'
express = require 'express'
uuid = require 'node-uuid'

app = require './app'
database = require './database'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


# List route

# TODO: for Export


## Detail route

# Catch 'id' parameter
.use '/:id', (request, response, next) ->
    request.suppliesId = request.params.id
    next()
    return

# Handle GET requests. Retrieve data from database.
.get '/:id', (request, response) ->
    database.getSupplies request.suppliesId, (error, supplies) ->
        if error?
            response.status(500).json
                detail: error
        else
            response.send
                supplies: supplies
        return
    return

# Handle PATCH requests.
.patch '/:id', (request, response) ->
    filter = id: request.suppliesId
    update =
        $set:
            description: request.body.description
    options =
        upsert: true
    database.supplies().updateOne filter, update, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else if result.upsertedCount is 1
            response.status(201).json
                details: 'Supplies successfully created.'
        else
            response.send
                details: 'Supplies successfully updated.'
        return
    return

# Handle DELETE requests.
.delete '/:id', (request, response) ->
    # TODO: If uuid is undefined then do a real delete instead of an update.
    filter = id: request.suppliesId
    update =
        $pull:
            persons:
                uuid: request.body.uuid
    options = {}
    database.supplies().updateOne filter, update, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            response.send
                details: 'Supplies successfully unapplied.'
        return
    return


## Route to apply new persons

# Handle POST requests.
.post '/:id/person', (request, response) ->
    person =
        id: request.body.id
        timestamp: +new Date() / 1000
        uuid: uuid.v4()
    filter = id: request.suppliesId
    update =
        $push:
            persons: person
    options =
        upsert: true
    database.supplies().updateOne filter, update, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            database.getSupplies request.suppliesId, (error, supplies) ->
                if error?
                    response.status(500).json
                        detail: error
                else if result.upsertedCount is 1
                    response.status(201).send
                        details: 'Supplies successfully created.'
                        supplies: supplies
                else
                    response.send
                        details: 'Supplies successfully updated.'
                        supplies: supplies
                return
        return
    return
