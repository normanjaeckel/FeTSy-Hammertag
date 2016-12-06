angular.module 'FeTSy-Hammertag.states.import', [
    'angularSpinner'
]


.controller 'ImportCtrl', [
    '$http'
    '$q'
    '$scope'
    'serverURL'
    ($http, $q, $scope, serverURL) ->
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
                    $scope.$apply =>
                        if results.data.length > 0
                            @isValid = _.every results.data, 'id'
                            if @isValid
                                @data = _.filter results.data, 'description'
                        else
                            @isValid = false
                        return
                    return
                error: (error, file) =>
                    $scope.$apply =>
                        @isValid = false
                        return
                    return
            return

        @submit = ->
            @submitted =
                pending: true
            request = (item) =>
                $http.patch "#{serverURL}/#{@type}/#{item.id}",
                    description: item.description
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
