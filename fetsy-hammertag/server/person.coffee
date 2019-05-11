debug = require('debug') 'fetsy-hammertag:server:person'
express = require 'express'
_ = require 'lodash'


app = require './app'
database = require './database'
permission = require './permission'
FeTSyError = require './error'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


# List route

# Handle get requests. Retrieve extended list of persons from database.
.get '/', (request, response) ->
    # Care of redundancy with client
    unknownPersonId = 'Unknown'

    database.person().find().sort( id: 1 ).toArray (error, documents) ->
        if error?
            response.status(500).json
                detail: error
        else
            for doc in documents
                if not _.isArray doc.id
                    doc.id = [doc.id]
            iterator = (object) ->
                object.id = [object.id] if not _.isArray object.id
                person = _.last object.persons or []
                if not person?
                    person =
                        id: unknownPersonId
                index = _.findIndex documents, (doc) -> person.id in doc.id
                if index is -1
                    documents.push
                        id: [person.id]
                        objects: [object]
                else
                    if not documents[index].objects?
                        documents[index].objects = []
                    documents[index].objects.push object
                return
            database.object().find().forEach iterator, (error) ->
                if error?
                    response.status(500).json
                        detail: error
                else
                    iterator = (supplies) ->
                        persons = supplies.persons or []
                        if persons.length is 0
                            persons.push
                                id: unknownPersonId
                        for person in persons
                            index = _.findIndex documents,
                                (doc) -> person.id in doc.id
                            if index is -1
                                newSuppliesObj = {}
                                newSuppliesObj[supplies.id] = supplies
                                documents.push
                                    id: [person.id]
                                    supplies: newSuppliesObj
                            else
                                if not documents[index].supplies?
                                    documents[index].supplies = {}
                                if not documents[index].supplies[supplies.id]?
                                    # coffeelint: disable=max_line_length
                                    documents[index].supplies[supplies.id] = supplies
                                    # coffeelint: enable=max_line_length
                        return
                    database.supplies().find().forEach iterator, (error) ->
                        if error?
                            response.status(500).json
                                detail: error
                        else
                            response.send
                                persons: documents
                        return
                return
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
            if not _.isArray result.id
                result.id = [result.id]
            response.send
                person: result
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
    database.person().findOne query, options
    .then (result) ->
        if result?
            throw new FeTSyError 'New person id already exists.', 400
        query = id: request.personId
        options = {}
        database.person().findOne query, options
    .then (result) ->
        filter = id: request.personId
        if not result? or not _.isArray result.id
            update =
                $set:
                    id: [request.personId, request.body.id]
        else
            update =
                $push:
                    id: request.body.id
        options =
            upsert: true
        database.person().updateOne filter, update, options
    .then (result) ->
        if result.upsertedCount is 1
            response.status(201).json
                details: 'Person with extra id successfully created.'
        else
            response.send
                details: 'Person with extra id successfully updated.'
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
    filter = id: request.personId
    update =
        $set:
            description: request.body.description
            company: request.body.company
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
    options = {}
    database.person().removeOne selector, options, (error, result) ->
        if error?
            response.status(500).json
                detail: error
        else
            response.send
                details: 'Person successfully deleted.'
        return
    return
