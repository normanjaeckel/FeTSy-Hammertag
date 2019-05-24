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
    # First we fetch all Persons and the requested supplies from database. Then
    # we build the list of pseudo person elements that should be pushed into
    # supplies.persons array (primary update operation). Then we go through a
    # complex logic to determine whether to update the max counter or not
    # (secondary update operation). Therefor we have to find out the current
    # entry of this max counter (or undefined if this is a new supplies apply).
    # If we have a max counter, we have to calculate the incrementing value
    # which can be positive or not. If not there won't be an update. If we have
    # no max counter at the moment we insert it into the document. Last step is
    # to run the database update.

    # Fetch supplies and all persons using promises
    suppliesDeferred = Q.defer()
    database.getSupplies request.suppliesId, (error, supplies) ->
        if error?
            suppliesDeferred.reject error
        else
            suppliesDeferred.resolve supplies
        return
    Q.all [
        suppliesDeferred.promise
        database.person().find().toArray()
    ]
    .done(
        ([supplies, allPersons]) ->
            # Prepare primary update operation
            personId = String request.body.id
            personList = _.times request.body.number, ->
                id: personId
                timestamp: +new Date() / 1000
                uuid: uuid.v4()
            update =
                $push:
                    persons:
                        $each: personList

            # Prepare secondary update operation (max counter)
            findPersonMaxCountElement = ->
                if supplies.personMaxCount?
                    person = _.find allPersons, (person) ->
                        person.id = [person.id] if not _.isArray person.id
                        personId in person.id
                    if person?
                        # Attention: We assume that there is only one element
                        # with matching id but the code does not check it.
                        element = _.find supplies.personMaxCount, (element) ->
                            element.id in person.id
                        if element?
                            person: person
                            element: element
                    # Else: return undefined
            found = findPersonMaxCountElement()
            if found?
                currentCount = _.reduce(
                    _.countBy supplies.persons, 'id'
                    (count, number, id) ->
                        if id in found.person.id
                            number + count
                        else
                            count
                    0
                )
                maxCount = found.element.maxCount
                incValue = request.body.number + currentCount - maxCount
                if incValue > 0
                    update.$inc =
                        'personMaxCount.$[element].maxCount': incValue
                    arrayFilters = [
                        'element.id':
                            # Attention: Once again we assume there is only one
                            # element with matching id but the code does not
                            # check it.
                            $in: found.person.id
                    ]
                # If not there is no extra update operation, arrayFilters
                # remains undefined
            else
                update.$push.personMaxCount =
                    id: personId
                    maxCount: request.body.number
                # arrayFilters remains undefined

            # Prepare last necessary arguments
            filter = id: supplies.id
            options =
                upsert: true
                arrayFilters: arrayFilters

            # Run database update
            database.supplies().updateOne(
                filter
                update
                options
                (error, result) ->
                    if error?
                        response.status(500).json
                            detail: error
                        return
                    database.getSupplies(
                        request.suppliesId
                        (error, supplies) ->
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
                    )
                    return
            )
            return
        (error) ->
            response.status(500).json
                detail: error
            return
    )
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


## Route to reset personMaxCount entry

# Attention: The permission check from above is still in use here.
.post '/:id/reset-max-count', (request, response) ->
    # Fetch supplies and all persons using promises
    suppliesDeferred = Q.defer()
    database.getSupplies request.suppliesId, (error, supplies) ->
        if error?
            suppliesDeferred.reject error
        else
            suppliesDeferred.resolve supplies
        return
    Q.all [
        suppliesDeferred.promise
        database.person().findOne
            id: request.body.personId
    ]
    .done(
        ([supplies, person]) ->
            # Parse person result
            if not person?
                person =
                    id: [request.body.personId]
            person.id = [person.id] if not _.isArray person.id

            # Prepare update operation
            currentCount = _.reduce(
                _.countBy supplies.persons, 'id'
                (count, number, id) ->
                    if id in person.id
                        number + count
                    else
                        count
                0
            )
            if currentCount > 0
                update =
                    $set:
                        'personMaxCount.$[element].maxCount': currentCount
                arrayFilters = [
                    'element.id':
                        # Attention: Once again we assume there is only one
                        # element with matching id but the code does not check
                        # it.
                        $in: person.id
                ]
            else
                # The option arrayFilters remains undefined
                update =
                    $pull:
                        personMaxCount:
                            id:
                                $in: person.id
                        # Attention: Once again we assume there is only one
                        # element with matching id but the code does not check
                        # it.

            filter = id: supplies.id
            options =
                arrayFilters: arrayFilters

            # Run database update
            database.supplies().updateOne(
                filter
                update
                options
                (error, result) ->
                    if error?
                        response.status(500).json
                            detail: error
                    else
                        response.send
                            details: 'Supplies person max count successfully ' +
                                     'reset.'
                            maxCount: currentCount
                    return
            )
            return
        (error) ->
            response.status(500).json
                detail: error
            return
    )
    return
