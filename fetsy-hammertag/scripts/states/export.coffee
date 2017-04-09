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
        # Helper to calculate the maximum number of ids
        @calcMaxIDs = (elements) ->
            maxElement = _.maxBy elements, 'id.length'
            maxElement?.id.length

        # Parse persons
        personPromise = $http.get "#{serverURL}/person"
        .then (response) =>
            result =
                fields: ['description', 'company']
                data: []
            maxIDs = @calcMaxIDs response.data.persons
            result.fields.push "id_#{num}" for num in [1..maxIDs]
            # Rename 'id_1' to 'id' for easier re-import of the export result.
            result.fields[2] = 'id'

            for person in response.data.persons
                if person.description?
                    result.data.push _.concat(
                        person.description
                        person.company
                        person.id
                    )

            resultData = 'data:text/csv;charset=utf-8,' + Papa.unparse result
            @persons =
                URI: encodeURI resultData
            return

        # Parse objects
        objectPromise = $http.get "#{serverURL}/object"
        .then (response) =>
            @objects =
                URI: encodeURI @parseObjectResponseData response.data.objects
            return

        # Helper to parse objects
        @parseObjectResponseData = (objects) =>
            result =
                fields: ['description']
                data: []
            maxIDs = @calcMaxIDs objects
            result.fields.push "id_#{num}" for num in [1..maxIDs]
            # Rename 'id_1' to 'id' for easier re-import of the export result.
            result.fields[1] = 'id'

            maxPersons = 1
            for object in objects
                item = _.concat object.description, object.id
                if maxIDs-object.id.length
                    item.push '' for num in [1..maxIDs-object.id.length]
                if object.persons?
                    for person in object.persons
                        # coffeelint: disable=max_line_length
                        description = person.description || DefaultDescription.person
                        description += " (#{person.company})" if person.company
                        timestamp = moment.unix(person.timestamp).format 'YYYY-MM-DD HH:mm'
                        item.push "#{person.id} · #{description} · #{timestamp}"
                        # coffeelint: enable=max_line_length
                result.data.push item
                if object.persons? and maxPersons < object.persons.length
                    maxPersons = object.persons.length
            result.fields.push "person_#{num}" for num in [1..maxPersons]

            'data:text/csv;charset=utf-8,' + Papa.unparse result


        # Parse supplies
        suppliesPromise = $http.get "#{serverURL}/supplies"
        .then (response) =>
            @supplies =
                URI: encodeURI @parseSuppliesResponseData response.data.supplies
            return

        # Helper to parse supplies
        @parseSuppliesResponseData = (allSupplies) ->
            result =
                fields: ['id', 'description', 'inventory', 'out', 'in']
                data: []

            maxPersons = 1
            for supplies in allSupplies
                item = [
                    supplies.id
                    supplies.description
                    supplies.inventory or 0
                    supplies.persons?.length or 0
                    (supplies.inventory or 0) - (supplies.persons?.length or 0)
                ]
                if supplies.persons?
                    for person in supplies.persons
                        # coffeelint: disable=max_line_length
                        description = person.description || DefaultDescription.person
                        description += " (#{person.company})" if person.company
                        timestamp = moment.unix(person.timestamp).format 'YYYY-MM-DD HH:mm'
                        item.push "#{person.id} · #{description} · #{timestamp}"
                        # coffeelint: enable=max_line_length
                result.data.push item
                if supplies.persons? and maxPersons < supplies.persons.length
                    maxPersons = supplies.persons.length
            result.fields.push "person_#{num}" for num in [1..maxPersons]

            'data:text/csv;charset=utf-8,' + Papa.unparse result

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
