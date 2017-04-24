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
        # CSV field separator
        @fieldSeparator = [',', ';']
        @fieldSeparatorDescription = ['Comma', 'Semicolon']
        @useMSExcelStyle = false

        # Helper to calculate the maximum number of ids
        @calcMaxIDs = (elements) ->
            maxElement = _.maxBy elements, 'id.length'
            maxElement?.id.length

        # Parse persons
        @getPersonPromise = (config) =>
            $http.get "#{serverURL}/person"
            .then (response) =>
                result =
                    fields: ['description', 'company']
                    data: []
                maxIDs = @calcMaxIDs response.data.persons
                result.fields.push "id_#{num}" for num in [1..maxIDs]
                # Rename 'id_1' to 'id' for easier re-import of the result of
                # this export.
                result.fields[2] = 'id'

                for person in response.data.persons
                    if person.description?
                        result.data.push _.concat(
                            person.description
                            person.company
                            person.id
                        )

                resultData = 'data:text/csv;charset=utf-8,' + Papa.unparse(
                    result
                    config
                )
                @persons =
                    URI: encodeURI resultData
                return

        # Parse objects
        @getObjectPromise = (config) =>
            $http.get "#{serverURL}/object"
            .then (response) =>
                @objects =
                    URI: encodeURI @parseObjectResponseData(
                        response.data.objects
                        config
                    )
                return

        # Helper to parse objects
        @parseObjectResponseData = (objects, config) =>
            result =
                fields: ['description']
                data: []
            maxIDs = @calcMaxIDs objects
            result.fields.push "id_#{num}" for num in [1..maxIDs]
            # Rename 'id_1' to 'id' for easier re-import of the result of
            # this export.
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
                        item.push person.id, description, timestamp
                        # coffeelint: enable=max_line_length
                result.data.push item
                if object.persons? and maxPersons < object.persons.length
                    maxPersons = object.persons.length
            for num in [1..maxPersons]
                result.fields.push(
                    "person_#{num}_id"
                    "person_#{num}_description"
                    "person_#{num}_timestamp"
                )

            'data:text/csv;charset=utf-8,' + Papa.unparse result, config

        # Parse supplies
        @getSuppliesPromise = (config) =>
            $http.get "#{serverURL}/supplies"
            .then (response) =>
                @supplies =
                    URI: encodeURI @parseSuppliesResponseData(
                        response.data.supplies
                        config
                    )
                return

        # Helper to parse supplies
        @parseSuppliesResponseData = (allSupplies, config) ->
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
                        item.push person.id, description, timestamp
                        # coffeelint: enable=max_line_length
                result.data.push item
                if supplies.persons? and maxPersons < supplies.persons.length
                    maxPersons = supplies.persons.length
            for num in [1..maxPersons]
                result.fields.push(
                    "person_#{num}_id"
                    "person_#{num}_description"
                    "person_#{num}_timestamp"
                )

            'data:text/csv;charset=utf-8,' + Papa.unparse result, config

        @boot = =>
            # A loading spinner is active.
            @ready = false
            config =
                delimiter: @fieldSeparator[0]
            config.delimiter = @fieldSeparator[1] if @useMSExcelStyle
            $q.all [
                @getPersonPromise config
                @getObjectPromise config
                @getSuppliesPromise config
            ]
            .then(
                =>
                    # Set timestamp and remove loading spinner.
                    @timestamp = +new Date() / 1000
                    @ready = true
                    return
                (error) ->
                    alert error.data
                    return
            )
            return

        # Now start export
        @boot()

        return
]
