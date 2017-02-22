angular.module 'FeTSy-Hammertag.states.database', [
    'angularSpinner'
]


.controller 'DatabaseCtrl', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        @focus = true
        @securityQuery = [
            _.random 1, 9
            _.random 1, 9
            _.random 1, 9
        ]
        @securityQueryResult = undefined
        @securityQuerySolved = ->
            @securityQueryResult is _.sum @securityQuery

        @dropDatabase = ->
            @submitted =
                pending: true
            $http.post "#{serverURL}/drop-database"
            .then(
                (response) =>
                    @submitted =
                        success: true
                    return
                (reason) =>
                    @submitted =
                        error: true
                    return
            )
            return

        return
]
