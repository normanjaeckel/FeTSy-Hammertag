angular.module 'FeTSy-Hammertag.states.scanInput', [
    'FeTSy-Hammertag.utils.objectUpdate'
    'FeTSy-Hammertag.utils.personUpdate'
]


.factory 'ScanInputValidationFactory', [
    () ->
        validateObject: (data) ->
            if not isNaN data
                parseInt data
            else
                null
        validatePerson: (data) ->
            data
]


.controller 'ScanInputCtrl', [
    '$http'
    'serverURL'
    'ScanInputValidationFactory'
    'ObjectUpdateFactory'
    'PersonUpdateFactory'
    ($http, serverURL, ScanInputValidationFactory, ObjectUpdateFactory, PersonUpdateFactory) ->
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
                        person = response.data.person
                        if person
                            @lastPerson =
                                id: person.personID
                                description: person.personDescription
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
            if personID and @lastObject? and @lastObject.id
                $http.patch "#{serverURL}/object/#{@lastObject.id}",
                    objectDescription: @objectDescription
                    personID: personID
                    personDescription: @personDescription
                .then(
                    (response) =>
                        @fetchPersonError = false
                        @lastObject.description = response.data.object
                            .objectDescription
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

        @updateObject = () ->
            ObjectUpdateFactory.update
                objectID: @lastObject.id
                objectDescription: @lastObject.description
            .then(
                (newObjectDescription) =>
                    @lastObject.description = newObjectDescription
                    return
            )
            return

        @updatePerson = () ->
            PersonUpdateFactory.update
                personID: @lastPerson.id
                personDescription: @lastPerson.description
            .then(
                (newPersonDescription) =>
                    @lastPerson.description = newPersonDescription
                    return
            )
            return

        @resetForm = ->
            @fetchObjectError = @fetchPersonError = false
            @lastObject = @lastPerson = null
            @objectID = @objectDescription = @personID = @personDescription = ''
            @focusObject = true
            return

        return
]
