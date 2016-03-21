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
                        if response.data.person
                            @lastPerson =
                                id: response.data.person.personID
                                description: response.data.person.personDescription
                        else
                            @lastPerson = null
                        @objectID = ''
                        @objectDescription = ''
                        @focusPerson = true
                        return
                    (response) =>
                        @fetchObjectError = true
                        @focusObject = true
                        return
                )
            else
                @focusObject = true
            return

        @scanPerson = ->
            personID = ScanInputValidationFactory.validatePerson @personID
            if personID and @lastObject and @lastObject.id
                $http.patch "#{serverURL}/object/#{@lastObject.id}",
                    objectDescription: @objectDescription
                    personID: personID
                    personDescription: @personDescription
                .then(
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
                        return
                    (response) =>
                        @fetchPersonError = true
                        @focusPerson = true
                        return
                )
            else
                @personID = ''
                @focusPerson = true
            return

        @resetForm = ->
            @fetchObjectError = @fetchPersonError = false
            @lastObject = @lastPerson = null
            @objectID = @objectDescription = @personID = @personDescription = ''
            @focusObject = true
            return

        return
]
