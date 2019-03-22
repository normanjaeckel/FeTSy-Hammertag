FeTSyError = (message, status) ->
    @message = message
    @status = status or 500
    return
FeTSyError.prototype = new Error()


module.exports = FeTSyError
