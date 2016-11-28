angular.module 'FeTSy-Hammertag.states.import', [
    'angularSpinner'
    'ngCsvImport'
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

        @csv =
            content: undefined
            accept: '.csv'
            header: true
            headerVisible: false
            separator: ','
            separatorVisible: false
            encoding: 'utf-8'
            encodingVisible: false
            result: undefined
            callback: ->

        $scope.$watch(
            =>
                @csv.result
            =>
                if @csv.result?
                    if Array.isArray @csv.result
                        isValid = true
                        for line in @csv.result
                            isValid = isValid and line.id and line.description
                        @isValid = Boolean isValid
                    else
                        @isValid = false
                return
        )

        @submit = ->
            @submitted =
                pending: true
            request = (id) =>
                $http.patch "#{serverURL}/#{@type}/#{id}",
                    description: item.description
            promises = (request item.id for item in @csv.result)
            $q.all promises
            .then(
                (responses) =>
                    @submitted =
                        success: responses.length
                (reason) =>
                    @submitted =
                        error: true
            )
            return

        return
]
