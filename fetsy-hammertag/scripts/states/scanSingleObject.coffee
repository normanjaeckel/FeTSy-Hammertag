angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'angularMoment'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.database'
    'FeTSy-Hammertag.utils.updateDescription'
    'FeTSy-Hammertag.utils.updateInventory'
    'FeTSy-Hammertag.utils.validation'
]



.controller 'ScanSingleObjectCtrl', [
    'DatabaseFactory'
    'DefaultDescription'
    'UpdateDescriptionFactory'
    'UpdateInventoryFactory'
    'ValidationFactory'
    (DatabaseFactory, DefaultDescription, UpdateDescriptionFactory,
     UpdateInventoryFactory, ValidationFactory) ->
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
                    if @lastPerson.description?
                        DatabaseFactory.saveObject(
                            @scanInputValue
                            @lastPerson.id
                        ).then(
                            (response) =>
                                @lastObject = response.data.object
                                @resetInputField()
                                return
                            errorHandling
                        )
                    else
                        @scanInputValue = ''
                        @error = 'Unknown person. Description is missing.'
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
                    if @lastPerson.description?
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
                        @scanInputValue = ''
                        @error = 'Unknown person. Description is missing.'
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

        @updateInventory = ->
            UpdateInventoryFactory.update
                id: @lastSupplies.id
                inventory: @lastSupplies.inventory or 0
            .then(
                (result) =>
                    @lastSupplies.inventory = result.newInventory
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
