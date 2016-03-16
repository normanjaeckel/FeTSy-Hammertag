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
            objectID = ScanInputValidationFactory.validateObject @objectID
            if objectID
                if @objectDescription
                    httpCall = $http.patch "#{serverURL}/object/#{objectID}",
                        objectDescription: @objectDescription
                else
                    httpCall = $http.get "#{serverURL}/object/#{objectID}"
                httpCall.then(
                    (response) =>
                        @fetchObjectError = false
                        @lastObject =
                            id: objectID
                            description: response.data.object.objectDescription
                        if response.data.person.personID
                            @lastPerson =
                                id: response.data.person.personID
                                description: response.data.person.personDescription
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
            personID = ScanInputValidationFactory.validatePerson @personID
            if personID
                if @lastObject.id
                    httpCall = $http.patch "#{serverURL}/object/#{@lastObject.id}",
                        objectDescription: @objectDescription
                        personID: personID
                        personDescription: @personDescription
                else
                    httpCall = undefined  # TODO
                httpCall.then(
                    (response) =>
                        @fetchPersonError = false
                        @lastObject.description = response.data.object.objectDescription
                        @lastPerson =
                            id: response.data.person.personID
                            description: response.data.person.personDescription
                        @objectDescription = ''
                        @personID = ''
                        @personDescription = ''
                        @focusObject = true
                        @saved = true  # TODO: Remove it
                    (response) =>
                        @fetchPersonError = true
                        @focusPerson = true
                )
            else
                @focusPerson = true
            return

        return
]
