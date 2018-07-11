angular.module 'FeTSy-Hammertag.states.import', [
    'angularSpinner'
]


.controller 'ImportCtrl', [
    '$http'
    '$q'
    '$timeout'
    'serverURL'
    ($http, $q, $timeout, serverURL) ->
        @typeMap =
            'person': 'persons'
            'object': 'objects'
            'supplies': 'supplies'

        @type = 'person'

        angular.element '#importInputFile'
        .on 'change', (event) =>
            file = event.target.files[0]
            Papa.parse event.target.files[0],
                header: true
                skipEmptyLines: true
                complete: (results, file) =>
                    $timeout =>
                        if results.data.length > 0
                            @isValid = _.every results.data, 'id'
                            if @isValid
                                @data = _.filter results.data, (item) ->
                                    item.description or item.inventory?
                        else
                            @isValid = false
                        return
                    return
                error: (error, file) =>
                    $timeout =>
                        @isValid = false
                        return
                    return
            return

        @submit = ->
            @submitted =
                pending: true
            request = (item) =>
                data = description: item.description
                if @type is 'person'
                    data.company = item.company
                    data.instruction = item.instruction
                if @type is 'object'
                    data.firstPersonId = item.first_person_id
                if @type is 'supplies' and parseInt item.inventory
                    data.inventory = parseInt item.inventory
                $http.patch "#{serverURL}/#{@type}/#{item.id}", data
            promises = (request item for item in @data)
            $q.all promises
            .then(
                (responses) =>
                    @submitted =
                        success: responses.length
                    return
                (reason) =>
                    @submitted =
                        error: true
                    return
            )
            return

        return
]
