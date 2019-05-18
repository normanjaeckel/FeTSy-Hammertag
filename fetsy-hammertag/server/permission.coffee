app = require './app'
FeTSyError = require './error'


module.exports =
    fullWritePermissionGranted: (username) ->
        result = false
        if app.enabled 'full write permission granted'
            result = true
        else
            admins = app.get 'admins'
            for admin in admins
                if username is admin
                    result = true
                    break
        return result

    permissionDenied: ->
        throw new FeTSyError(
            'Permission denied. Please check your username.'
            403
        )
        return
