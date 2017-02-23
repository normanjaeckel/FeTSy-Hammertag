FeTSyError = (message) ->
    @message = message
    return
FeTSyError.prototype = new Error()


module.exports = FeTSyError
