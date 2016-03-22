angular.module 'FeTSy-Hammertag.controllers', [
    'FeTSy-Hammertag.personUpdate'
]


.controller 'NavbarCtrl', [
    () ->
]


.controller 'ScanInputCtrl', [
    '$http'
    'serverURL'
    'ScanInputValidationFactory'
    'PersonUpdateFactory'
    ($http, serverURL, ScanInputValidationFactory, PersonUpdateFactory) ->
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


.controller 'ListObjectsCtrl', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        $http.get "#{serverURL}/object"
        .then(
            (response) =>
                @objects = response.data
                return
        )
        @remove = (objectID) ->
            $http.delete "#{serverURL}/object/#{objectID}"
            .then(
                (response) =>
                    delete @objects[objectID]
                    return
            )
            return
        return
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'PersonUpdateFactory'
    ($http, serverURL, PersonUpdateFactory) ->
        $http.get "#{serverURL}/person"
        .then(
            (response) =>
                @persons = response.data
                return
        )

        @update = (personID) ->
            PersonUpdateFactory.update
                personID: personID
                personDescription: @persons[personID]
            .then(
                (newPersonDescription) =>
                    @persons[personID] = newPersonDescription
                    return
            )
            return

        @delete = (personID) ->
            $http.delete "#{serverURL}/person/#{personID}"
            .then(
                (response) =>
                    delete @persons[personID]
                    return
            )
            return
        return
]
