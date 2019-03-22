debug = require('debug') 'fetsy-hammertag:server:dropDatabase'
express = require 'express'


app = require './app'
database = require './database'
permission = require './permission'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'

.post '/', (request, response) ->
    if not permission.writePermissionGranted request.get('Auth-User')
        permission.permissionDenied()
    database.dropDatabase()
    .then(
        (result) ->
            message = 'Database successfully dropped.'
            debug message
            response.send
                details: message
            return
        (error) ->
            response.status(500).json
                detail: error
            return
    )
    return
