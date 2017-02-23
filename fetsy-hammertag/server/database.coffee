debug = require('debug') 'fetsy-hammertag:database'
mongodb = require 'mongodb'
_ = require 'lodash'

client = mongodb.MongoClient
_database = undefined

module.exports =
    connect: ->
        url = 'mongodb://localhost/fetsy-hammertag'
        client.connect url
        .then(
            (database) ->
                _database = database
                debug 'Connected successfully to database'
                return
            (error) ->
                console.error 'Error connecting to database.'
                process.exit 1
                return
        )

    object: ->
        _database.collection 'object'

    getObject: (id, callback) ->
        query = id: id
        options = {}
        @object().findOne query, options, (error, object) =>
            if error?
                callback error
            if not object?
                callback null,
                    id: [id]
            else
                object.id = [object.id] if not _.isArray object.id
                if not object.persons
                    callback null, object
                else
                    query =
                        id:
                            $in: (person.id for person in object.persons)
                    @person().find(query).toArray (error, documents) ->
                        if error?
                            callback error
                        persons = []
                        for person in object.persons
                            found = _.find documents, (doc) ->
                                if _.isArray doc.id
                                    person.id in doc.id
                                else
                                    person.id is doc.id
                            persons.push
                                id: if found? then found.id else [person.id]
                                timestamp: person.timestamp
                                description: found?.description
                        object.persons = persons
                        callback null, object
                        return
            return
        return

    supplies: ->
        _database.collection 'supplies'

    getSupplies: (id, callback) ->
        query = id: id
        options = {}
        @supplies().findOne query, options, (error, result) ->
            if error?
                callback error
            if not result?
                callback null,
                    id: id
            else
                callback null, result
            return
        return

    person: ->
        _database.collection 'person'

    dropDatabase: ->
        _database.dropDatabase()
