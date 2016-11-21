debug = require('debug') 'fetsy-hammertag:server:person'
express = require 'express'
_ = require 'lodash'

app = require './app'
database = require './database'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


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
            response.sendStatus 400
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
            response.sendStatus 400
        else if result.upsertedCount is 1
            response.sendStatus 201
        else
            response.sendStatus 200
        return
    return
