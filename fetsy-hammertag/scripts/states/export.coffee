angular.module 'FeTSy-Hammertag.states.export', [
    'angularMoment'
    'angularSpinner'
]


.controller 'ExportCtrl', [
    '$http'
    '$q'
    'moment'
    'serverURL'
    ($http, $q, moment, serverURL) ->
        # Parse persons
        personPromise = $http.get "#{serverURL}/person"
        .then (response) =>
            persons = []
            for person in response.data.persons
                if person.description?
                    persons.push
                        id: person.id
                        description: person.description
            persons = 'data:text/csv;charset=utf-8,' + Papa.unparse persons
            @persons =
                URI: encodeURI persons
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
                    for person in object.persons
                        timestamp = moment.unix(person.timestamp).format 'YYYY-MM-DD HH:mm'
                        item.push "#{person.id} · #{timestamp}"
                objects.data.push item
                if object.persons? and maxPersons < object.persons.length
                    maxPersons = object.persons.length
            objects.fields.push "Person#{num}" for num in [1..maxPersons]
            objects = 'data:text/csv;charset=utf-8,' + Papa.unparse objects
            @objects =
                URI: encodeURI objects
            return

        # Parse supplies
        # TODO

        # Remove loading spinner
        $q.all [personPromise, objectPromise]
        .then =>
            @timestamp = +new Date() / 1000
            @ready = true
            return

        return
]
