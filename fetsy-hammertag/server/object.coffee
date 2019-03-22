debug = require('debug') 'fetsy-hammertag:server:object'
express = require 'express'
Q = require 'q'
_ = require 'lodash'


app = require './app'
database = require './database'
permission = require './permission'
FeTSyError = require './error'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


## List route

# Handle get requests.
.get '/', (request, response) ->
    Q.all [
        database.object().find().sort( id: 1 ).toArray()
        database.person().find().toArray()
    ]
    .done(
        ([objects, persons]) ->
            personsObj = {}
            for person in persons
                person.id = [person.id] if not _.isArray person.id
                for id in person.id
                    personsObj[id] = person
            for object in objects
                object.id = [object.id] if not _.isArray object.id
                if object.persons?
                    for person in object.persons
                        if personsObj[person.id]?
                            person.description = personsObj[person.id]
                                .description
                            person.company = personsObj[person.id].company
                            person.id = personsObj[person.id].id
            response.send
                objects: objects
            return
        (error) ->
            response.status(500).json
                detail: error
            return
    )
    return


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

# Check permissions for the following write paths
.use (request, response, next) ->
    if not permission.writePermissionGranted request.get('Auth-User')
        permission.permissionDenied()
    next()
    return

# Handle POST requests.
.post '/:id', (request, response) ->
    query = id: request.body.id
    options = {}
    database.object().findOne query, options
    .then (result) ->
        if result?
            throw new FeTSyError 'New object id already exists.', 400
        query = id: request.objectId
        options = {}
        database.object().findOne query, options
    .then (result) ->
        filter = id: request.objectId
        if not result? or not _.isArray result.id
            update =
                $set:
                    id: [request.objectId, request.body.id]
        else
            update =
                $push:
                    id: request.body.id
        options =
            upsert: true
        database.object().updateOne filter, update, options
    .then (result) ->
        if result.upsertedCount is 1
            response.status(201).json
                details: 'Object with extra id successfully created.'
        else
            response.send
                details: 'Object with extra id successfully updated.'
        return
    .catch (error) ->
        if error instanceof FeTSyError
            response.status error.status
            .json
                detail: error
        else
            response.status 500
            .json
                detail: error
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
    options = {}
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
# ATTENTION: The permission check from above is also active here.
.post '/:id/person', (request, response) ->
    person =
        id: String request.body.id
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
