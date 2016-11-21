angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'angularMoment'
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
        saveSupplies: (ID, personID) ->
            $http.patch "#{serverURL}/supplies/#{ID}",
                personID: personID
                number: 1
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

            if type is 'person'
                @lastPerson = @lastObject = @lastSupplies = null
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
            else if type is 'singleObject'
                @lastSupplies = null
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
                    DatabaseFactory.fetchObject(@scanInputValue)
                    .then(
                        (response) =>
                            @lastObject = response.data.object
                            @resetInputField()
                            return
                        errorHandling
                    )
            else if type is 'supplies'
                @lastObject = null
                if @lastPerson
                    DatabaseFactory.saveSupplies(
                        @scanInputValue
                        @lastPerson.id
                    ).then(
                        (response) =>
                            @lastSupplies =
                                id: @scanInputValue
                                description: response.data.supplies
                                    .suppliesDescription
                                count: response.data.supplies.items.length
                            @resetInputField()
                            return
                        errorHandling
                    )
                else
                    DatabaseFactory.fetchSupplies(@scanInputValue)
                    .then(
                        (response) =>
                            @lastSupplies =
                                id: @scanInputValue
                                description: response.data.supplies
                                    .suppliesDescription
                                count: response.data.supplies.items.length
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
                (result) =>
                    @lastObject.description = result.newDescription
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @updateSupplies = ->
            UpdateDescriptionFactory.update
                type: 'supplies'
                ID: @lastSupplies.id
                description: @lastSupplies.description
            .then(
                (result) =>
                    @lastSupplies.description = result.newDescription
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
                (result) =>
                    @lastPerson.description = result.newDescription
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
