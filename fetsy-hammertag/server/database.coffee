debug = require('debug') 'fetsy-hammertag:database'
mongodb = require 'mongodb'

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
