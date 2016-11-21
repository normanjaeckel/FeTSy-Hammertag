bodyParser = require 'body-parser'
db = require './db'
express = require 'express'


## Initiate Express app and setup config

app = express()
app.enable 'strict routing'


## Parse JSON request body

app.use bodyParser.json()


## Export app

module.exports = app
