angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'FeTSy-Hammertag.utils.updateDescription'
    'FeTSy-Hammertag.utils.validation'
]


.factory 'DatabaseFactory', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        fetchObject: (ID) ->
            $http.get "#{serverURL}/object/#{ID}"
        fetchSupplies: (ID) ->
            $http.get "#{serverURL}/supplies/#{ID}"
        fetchPerson: (ID) ->
            $http.get "#{serverURL}/person/#{ID}"
        saveObject: (ID, personID) ->
            $http.patch "#{serverURL}/object/#{ID}",
                personID: personID
]


.controller 'ScanSingleObjectCtrl', [
    'DatabaseFactory'
    'UpdateDescriptionFactory'
    'ValidationFactory'
    (DatabaseFactory, UpdateDescriptionFactory, ValidationFactory) ->
        @scan = =>
            errorHandling = (response) =>
                @scanInputValue = ''
                @focusScanInput = true
                if response.data
                    @error = response.data.details
                else
                    @error = 'Connection failed. Please reload the page.'
                return

            type = ValidationFactory.validateInput @scanInputValue

            if type is 'singleObject'
                if @lastObject and @lastPerson
                    @lastObject = @lastPerson = null
                if @lastSupplies and @lastPerson
                    @lastSupplies = @lastPerson = null
                if @lastPerson
                    DatabaseFactory.saveObject(@scanInputValue, @lastPerson.id)
                    .then(
                        (response) =>
                            @lastObject =
                                id: @scanInputValue
                                description: response.data.object
                                    .objectDescription
                            @resetInputField()
                            return
                        errorHandling
                    )
                else
                    @lastSupplies = null
                    DatabaseFactory.fetchObject(@scanInputValue)
                    .then(
                        (response) =>
                            @lastObject =
                                id: @scanInputValue
                                description: response.data.object
                                    .objectDescription
                            person = response.data.person
                            if person
                                @lastPerson =
                                    id: person.personID
                                    description: person.personDescription
                            @resetInputField()
                            return
                        errorHandling
                    )
            else if type is 'person'
                if @lastSupplies and @lastPerson
                    @lastSupplies = @lastPerson = null
                if @lastObject
                    DatabaseFactory.saveObject(@lastObject.id, @scanInputValue)
                    .then(
                        (response) =>
                            @lastPerson =
                                id: @scanInputValue
                                description: response.data.person
                                    .personDescription
                            @resetInputField()
                            return
                        errorHandling
                    )
                else if @lastSupplies
                    console.log 'TODO Save supplies to pers'
                else
                    DatabaseFactory.fetchPerson(@scanInputValue)
                    .then(
                        (response) =>
                            @lastPerson =
                                id: @scanInputValue
                                description: response.data.person
                                    .personDescription
                            @resetInputField()
                            return
                        errorHandling
                    )
            else if type is 'massObject'
                if @lastObject and @lastPerson
                    @lastObject = @lastPerson = null
                if @lastSupplies and @lastPerson
                    @lastSupplies = @lastPerson = null
                if @lastPerson
                    console.log 'TODO Add this obj to person'
                else
                    @lastObject = null
                    DatabaseFactory.fetchSupplies(@scanInputValue)
                    .then(
                        (response) =>
                            console.log response.data
                            @lastSupplies =
                                id: @scanInputValue
                                description: response.data.supplies
                                    .suppliesDescription
                            @resetInputField()
                            return
                        errorHandling
                    )
            else
                @error = 'Invalid code. Please reset form field and try again.'
                @focusScanInput = true
            return

        @updateObject = ->
            UpdateDescriptionFactory.update
                type: 'object'
                ID: @lastObject.id
                description: @lastObject.description
            .then(
                (newDescription) =>
                    @lastObject.description = newDescription
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @updatePerson = ->
            UpdateDescriptionFactory.update
                type: 'person'
                ID: @lastPerson.id
                description: @lastPerson.description
            .then(
                (newDescription) =>
                    @lastPerson.description = newDescription
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @resetInputField = ->
            @scanInputValue = ''
            @error = ''
            @focusScanInput = true
            return

        @resetForm = ->
            @lastObject = @lastPerson = @lastSupplies = null
            @resetInputField()
            return

        @resetForm()

        return
]
