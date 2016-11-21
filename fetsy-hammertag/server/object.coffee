debug = require('debug') 'fetsy-hammertag:server:object'
express = require 'express'
_ = require 'lodash'

app = require './app'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'


## Detail route

# Catch 'id' parameter
.use '/:id', (request, response, next) ->
    request.objectID = request.params.id
    response.data = {}
    next()
    return

# Handle GET requests. Retrieve data from database.
.get '/:id', (request, response, next) ->
    # Hard coded object here.
    object =
        id: request.objectID
        description: 'Hard coded object description here.'
        persons: [
            id: 45645654
            description: "Hard coded name Max"
            timestamp: +new Date() / 1000
        ,
            id: 98754366
            description: "Hard coded name Maxi"
            timestamp: +new Date() / 1000
        ,
            id: 12365478
            description: "Hard coded name Hansi"
            timestamp: +new Date() / 1000
        ]
    _.assign response.data,
        object: object
    response.send response.data
    return
