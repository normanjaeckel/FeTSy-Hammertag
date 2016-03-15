http = require 'http'

http.createServer (request, response) ->
    request.on 'error', (err) ->
        console.error err
        response.statusCode = 400
        response.end()
        return
    .on 'data', ->
        return
    .on 'end', ->

        response.on 'error', (err) ->
            console.error(err)
            return
        .end 'sdfsdfsdf'
        return
    return
.listen 8080
