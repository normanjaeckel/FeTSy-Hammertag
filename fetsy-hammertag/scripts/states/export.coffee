angular.module 'FeTSy-Hammertag.states.export', []


.controller 'ExportCtrl', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        $http.get "#{serverURL}/all"
        .then(
            (response) =>
                @persons = []
                angular.forEach response.data, (data, personID) =>
                    @persons.push
                        ID: personID
                        Description: data.description
                    return

                @persons = 'data:text/csv;charset=utf-8,' + Papa.unparse @persons

                @persons = encodeURI @persons

                return
        )
        return
]
