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
            maxIDs = 0
            result =
                fields: ['description']
                data: []
            for person in response.data.persons
                if person.description?
                    result.data.push _.concat person.description, person.id
                    if maxIDs < person.id.length
                        maxIDs = person.id.length
            result.fields.push "id_#{num}" for num in [1..maxIDs]
            # Rename 'id_1' to 'id' for easier re-import of the export result.
            result.fields[1] = 'id'
            resultData = 'data:text/csv;charset=utf-8,' + Papa.unparse result
            @persons =
                URI: encodeURI resultData
            return

        # Helper to parse objects and supplies
        @parseResponseData = (data, withInventory) ->
            maxPersons = 0
            result =
                fields: ['id', 'description']
                data: []
            result.fields.push 'inventory', 'out', 'in' if withInventory
            for element in data
                item = [element.id, element.description]
                total = element.inventory or 0
                out = element.persons?.length or 0
                stillIn = total - out
                item.push total, out, stillIn if withInventory
                if element.persons?
                    for person in element.persons
                        # coffeelint: disable=max_line_length
                        description = person.description || DefaultDescription.person
                        timestamp = moment.unix(person.timestamp).format 'YYYY-MM-DD HH:mm'
                        item.push "#{person.id} · #{description} · #{timestamp}"
                        # coffeelint: enable=max_line_length
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
                URI: @parseResponseData response.data.objects
            return

        # Parse supplies
        suppliesPromise = $http.get "#{serverURL}/supplies"
        .then (response) =>
            @supplies =
                URI: @parseResponseData response.data.supplies, true
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
