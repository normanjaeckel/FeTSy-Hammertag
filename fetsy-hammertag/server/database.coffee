debug = require('debug') 'fetsy-hammertag:database'
mongodb = require 'mongodb'
_ = require 'lodash'

client = mongodb.MongoClient
_database = undefined

module.exports =
    connect: ->
        url = 'mongodb://localhost/fetsy-hammertag'
        client.connect url, (error, database) ->
            if error
                console.error 'Error connecting to database.'
                process.exit 1
            _database = database
            debug 'Connected successfully to database'

    object: ->
        _database.collection 'object'

    getObject: (id, callback) ->
        query = id: id
        options = {}
        @object().findOne query, options, (error, result) =>
            if error?
                callback error
            if not result?
                callback null,
                    id: id
                    description: 'Unknown object'
            else
                if not result.description?
                    result.description = 'Unknown object'
                query =
                    id:
                        $in: (person.id for person in result.persons or [])
                @person().find(query).toArray (error, documents) ->
                    if error?
                        callback error
                    persons = []
                    for person in result.persons or []
                        found = _.find documents, (doc) -> doc.id is person.id
                        persons.push
                            id: person.id
                            timestamp: person.timestamp
                            description: if found? then found.description else 'Unknown'
                    result.persons = persons
                    callback null, result
                    return
            return
        return

    person: ->
        _database.collection 'person'
