express = require 'express'
app = express()

app.use express.static __dirname

app.get '/api', (req, res) ->
  res.send 'Hello World!'

app.listen 8080, ->
  console.log 'Example app listening on port 8080!'
