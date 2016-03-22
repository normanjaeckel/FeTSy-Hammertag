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
    '$uibModal'
    'serverURL'
    ($http, $uibModal, serverURL) ->
        $http.get "#{serverURL}/person"
        .then(
            (response) =>
                @persons = response.data
                return
        )
        @update = (personID, personDescription) ->
            if personDescription is 'Unknown'
                personDescription = ''
            $uibModal.open
                controller: 'PersonUpdateCtrl as personUpdate'
                templateUrl: 'static/templates/personUpdate.html'
                resolve:
                    person: () ->
                        personID: personID
                        personDescription: personDescription
            .result.then(
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


.controller 'PersonUpdateCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'person'
    ($http, $uibModalInstance, serverURL, person) ->
        @person = person
        @focus = true
        @save = ->
            if @person.personDescription
                $http.patch "#{serverURL}/person/#{@person.personID}",
                    personDescription: @person.personDescription
                .then(
                    (response) =>
                        $uibModalInstance.close @person.personDescription
                        return
                )
            return
        return
]
