express = require 'express'

module.exports = (params) ->
    app = params.app

    express.Router
        caseSensitive: app.get 'case sensitive routing'
        strict: app.get 'strict routing'

    .get '/', (request, response) ->
        response.sendStatus 200
