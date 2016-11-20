express = require 'express'

app = require './app'


module.exports = express.Router
    caseSensitive: app.get 'case sensitive routing'
    strict: app.get 'strict routing'

.get '/', (request, response) ->
    response.sendStatus 200
