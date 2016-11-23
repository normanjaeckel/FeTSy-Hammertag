angular.module 'FeTSy-Hammertag.states.export', [
    'angularSpinner'
    'FeTSy-Hammertag.utils.contentDefaults'
]


.controller 'ExportCtrl', [
    '$http'
    '$q'
    'serverURL'
    'UnknownPersonId'
    ($http, $q, serverURL, UnknownPersonId) ->
        # Parse persons
        personPromise = $http.get "#{serverURL}/person"
        .then (response) =>
            persons = response.data.persons
            angular.forEach persons, (person) ->
                delete person['_id']
            persons = 'data:text/csv;charset=utf-8,' + Papa.unparse persons
            @persons =
                URI: encodeURI persons
                timestamp: +new Date() / 1000
            return

        # Parse objects
        objectPromise = $http.get "#{serverURL}/object"
        .then (response) =>
            maxPersons = 0
            objects =
                fields: ['id', 'description']
                data: []
            for object in response.data.objects
                item = [object.id, object.description]
                if object.persons?
                    item.push "#{person.id} · #{person.timestamp}" for person in object.persons
                objects.data.push item
                if object.persons? and maxPersons < object.persons.length
                    maxPersons = object.persons.length
            objects.fields.push "Person#{num}" for num in [1..maxPersons]
            objects = 'data:text/csv;charset=utf-8,' + Papa.unparse objects
            @objects =
                URI: encodeURI objects
                timestamp: +new Date() / 1000
            return

        # Parse supplies
        # TODO

        # Remove loading spinner
        $q.all [personPromise, objectPromise]
        .then =>
            @ready = true
            return

        return
]
