angular.module 'FeTSy-Hammertag.states.export', [
    'angularMoment'
    'angularSpinner'
    'FeTSy-Hammertag.utils.contentDefaults'
]


.controller 'ExportCtrl', [
    '$http'
    '$q'
    'moment'
    'serverURL'
    'DefaultDescription'
    ($http, $q, moment, serverURL, DefaultDescription) ->
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

        # Helper to parse objects and supplies
        parseResponseData = (data) ->
            maxPersons = 0
            result =
                fields: ['id', 'description']
                data: []
            for element in data
                item = [element.id, element.description]
                if element.persons?
                    for person in element.persons
                        description = person.description || DefaultDescription.person
                        timestamp = moment.unix(person.timestamp).format 'YYYY-MM-DD HH:mm'
                        item.push "#{person.id} · #{description} · #{timestamp}"
                result.data.push item
                if element.persons? and maxPersons < element.persons.length
                    maxPersons = element.persons.length
            result.fields.push "person_#{num}" for num in [1..maxPersons]
            resultData = 'data:text/csv;charset=utf-8,' + Papa.unparse result
            encodeURI resultData

        # Parse objects
        objectPromise = $http.get "#{serverURL}/object"
        .then (response) =>
            @objects =
                URI: parseResponseData response.data.objects
            return

        # Parse supplies
        suppliesPromise = $http.get "#{serverURL}/supplies"
        .then (response) =>
            @supplies =
                URI: parseResponseData response.data.supplies
            return

        # Remove loading spinner
        $q.all [personPromise, objectPromise, suppliesPromise]
        .then(
            =>
                @timestamp = +new Date() / 1000
                @ready = true
                return
            (error) ->
                alert error.data
                return
        )
        return
]
