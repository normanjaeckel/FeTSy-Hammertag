angular.module 'FeTSy-Hammertag.controllers', []


.controller 'NavbarCtrl', [
    () ->
]


.controller 'ScanInputCtrl', [
    '$http'
    'serverURL'
    'ScanInputValidationFactory'
    ($http, serverURL, ScanInputValidationFactory) ->
        @focusObject = true
        @focusPerson = not @focusObject

        @scanObject = ->
            data = ScanInputValidationFactory.validateObject @objectID
            if data
                $http.get "#{serverURL}/object/#{@objectID}/"
                .then(
                    (response) =>
                        @fetchObjectError = false
                        @lastObject =
                            id: @objectID
                            description: @objectDescription or data.objectDescription
                        if data.personID
                            @lastPerson =
                                id: data.personID
                                description: data.personDescription
                        else
                            @lastPerson = null
                        @objectID = ''
                        @objectDescription = ''
                        @focusPerson = true
                    (response) =>
                        @fetchObjectError = true
                        @focusObject = true
                )
            else
                @focusObject = true
            return

        @scanPerson = ->
            data = ScanInputValidationFactory.validatePerson @personID
            if data
                $http.get "#{serverURL}/person/#{@personID}/"
                .then(
                    (response) =>
                        @fetchPersonError = false
                        @lastPerson =
                            id: @personID
                            description: @personDescription or data.personDescription
                        @personID = ''
                        @personDescription = ''
                        @focusObject = true
                        @saveData()
                    (response) =>
                        @fetchPersonError = true
                        @focusPerson = true
                )
            else
                @focusPerson = true
            return

        @saveData = ->
            @saved = true

        return
]
