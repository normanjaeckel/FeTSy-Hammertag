debug = require('debug') 'fetsy-hammertag:server:supplies'
express = require 'express'
uuid = require 'uuid'
Q = require 'q'
_ = require 'lodash'


app = require './app'
database = require './database'
permission = require './permission'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


## List route

# Handle get requests.
.get '/', (request, response) ->
    Q.all [
        database.supplies().find().sort( id: 1 ).toArray()
        database.person().find().toArray()
    ]
    .done(
        ([suppliesArray, persons]) ->
            personsObj = {}
            for person in persons
                person.id = [person.id] if not _.isArray person.id
                for id in person.id
                    personsObj[id] = person
            for supplies in suppliesArray
                if supplies.persons?
                    for person in supplies.persons
                        if personsObj[person.id]?
                            person.description = personsObj[person.id]
                                .description
                            person.company = personsObj[person.id].company
                            person.id = personsObj[person.id].id
            response.send
                supplies: suppliesArray
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


## Route to apply new persons

# Handle POST requests.
.post '/:id/person', (request, response) ->
    personList = _.times request.body.number, ->
        id: String request.body.id
        timestamp: +new Date() / 1000
        uuid: uuid.v4()
    filter = id: request.suppliesId
    update =
        $push:
            persons:
                $each: personList
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


# Detail write routes

# Handle DELETE requests.
.delete '/:id', (request, response) ->
    # TODO: If uuid is undefined then do a real delete instead of an update.
    if not _.isArray request.body.uuidList
        response.status(500).json
            detail: 'The property uuidList must be an array.'
    else
        filter = id: request.suppliesId
        update =
            $pull:
                persons:
                    uuid:
                        $in: request.body.uuidList
        options = {}
        # coffeelint: disable=max_line_length
        database.supplies().updateOne filter, update, options, (error, result) ->
        # coffeelint: enable=max_line_length
            if error?
                response.status(500).json
                    detail: error
            else
                response.send
                    details: 'Supplies successfully unapplied.'
            return
    return

# Check permissions for the following write routes
.use (request, response, next) ->
    if not permission.fullWritePermissionGranted request.get('Auth-User')
        permission.permissionDenied()
    next()
    return

# Handle PATCH requests.
.patch '/:id', (request, response) ->
    fields = {}
    fields.description = request.body.description if request.body.description?
    fields.inventory = request.body.inventory if request.body.inventory?

    filter = id: request.suppliesId
    update =
        $set: fields
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
