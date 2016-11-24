angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'angularMoment'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.updateDescription'
    'FeTSy-Hammertag.utils.validation'
]


.factory 'DatabaseFactory', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        fetchObject: (id) ->
            $http.get "#{serverURL}/object/#{id}"
        fetchSupplies: (id) ->
            $http.get "#{serverURL}/supplies/#{id}"
        fetchPerson: (id) ->
            $http.get "#{serverURL}/person/#{id}"
        saveObject: (id, personId) ->
            $http.post "#{serverURL}/object/#{id}/person",
                id: personId
        saveSupplies: (id, personId) ->
            $http.post "#{serverURL}/supplies/#{id}/person",
                id: personId
                number: 1  # Hard coded value about how many supplies should be applied
]


.controller 'ScanSingleObjectCtrl', [
    'DatabaseFactory'
    'DefaultDescription'
    'UpdateDescriptionFactory'
    'ValidationFactory'
    (DatabaseFactory, DefaultDescription, UpdateDescriptionFactory, ValidationFactory) ->
        @DefaultDescription = DefaultDescription

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
                            @lastPerson = response.data.person
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
                            @lastObject = response.data.object
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
                            @lastSupplies = response.data.supplies
                            @resetInputField()
                            return
                        errorHandling
                    )
                else
                    DatabaseFactory.fetchSupplies(@scanInputValue)
                    .then(
                        (response) =>
                            if not response.data.supplies.persons?
                                response.data.supplies.persons = []
                            @lastSupplies = response.data.supplies
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
                id: @lastObject.id
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
                id: @lastSupplies.id
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
                id: @lastPerson.id
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
            @showAll = false
            @focusScanInput = true
            return

        @resetForm = ->
            @lastObject = @lastPerson = @lastSupplies = null
            @resetInputField()
            return

        @resetForm()

        return
]
