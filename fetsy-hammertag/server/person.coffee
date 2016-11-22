debug = require('debug') 'fetsy-hammertag:server:person'
express = require 'express'
_ = require 'lodash'

app = require './app'
database = require './database'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


# List route

# Handle get requests. Retrieve extended list of persons from database.
.get '/', (request, response) ->
    database.person().find().sort( id: 1 ).toArray (error, documents) ->
        if error?
            response.status(500).json
                detail: error
        else
            # TODO: Add currently applied objects here.
            response.send
                persons: documents
        return
    return


## Detail route

# Catch 'id' parameter
.use '/:id', (request, response, next) ->
    request.personId = request.params.id
    next()
    return

# Handle GET requests. Retrieve data from database.
.get '/:id', (request, response) ->
    query = id: request.personId
    options = {}
    database.person().findOne query, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            if not result?
                result =
                    id: request.personId
                    description: 'Unknown'
            response.send
                person: result
        return
    return

# Handle PATCH requests.
.patch '/:id', (request, response) ->
    filter = id: request.personId
    update =
        $set:
            description: request.body.description
    options =
        upsert: true
    database.person().updateOne filter, update, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else if result.upsertedCount is 1
            response.status(201).json
                details: 'Person successfully created.'
        else
            response.send
                details: 'Person successfully updated.'
        return
    return

# Handle DELETE requests.
.delete '/:id', (request, response) ->
    selector = id: request.personId
    option = {}
    database.person().removeOne selector, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            response.send
                details: 'Person successfully deleted.'
        return
    return
