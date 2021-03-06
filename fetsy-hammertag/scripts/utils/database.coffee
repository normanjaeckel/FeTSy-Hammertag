angular.module 'FeTSy-Hammertag.utils.database', []


.factory 'DatabaseFactory', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        fetchObject: (id) ->
            $http.get "#{serverURL}/object/#{id}"
        fetchSupplies: (id) ->
            $http.get "#{serverURL}/supplies/#{id}"
        fetchPerson: (id) ->
            $http.get "#{serverURL}/person/#{id}"
        saveObject: (id, personId) ->
            $http.post "#{serverURL}/object/#{id}/person",
                id: personId
        saveSupplies: (id, personId, number) ->
            number = number or 1
            $http.post "#{serverURL}/supplies/#{id}/person",
                id: personId
                number: number
]
