angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'angularMoment'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.database'
    'FeTSy-Hammertag.utils.dialog'
    'FeTSy-Hammertag.utils.validation'
]


.controller 'ScanSingleObjectCtrl', [
    'DatabaseFactory'
    'DefaultDescription'
    'DialogFactory'
    'ValidationFactory'
    (DatabaseFactory, DefaultDescription, DialogFactory, ValidationFactory) ->
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
            else if type is 'object'
                @lastSupplies = null
                if @lastPerson
                    if @lastPerson.description?
                        DatabaseFactory.saveObject(
                            @scanInputValue
                            _.last @lastPerson.id
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
                            _.last @lastPerson.id
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

        @updatePersonDescription = ->
            DialogFactory.updateDescription
                type: 'person'
                item: @lastPerson
            .then(
                (result) =>
                    @lastPerson.description = result.newDescription
                    return
                (error) ->
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @addPersonID = ->
            DialogFactory.addID
                type: 'person'
                item: @lastPerson
            .then(
                (result) =>
                    @lastPerson.id = result.newIDs
                    return
                (error) ->
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @updateObjectDescription = ->
            DialogFactory.updateDescription
                type: 'object'
                item: @lastObject
            .then(
                (result) =>
                    @lastObject.description = result.newDescription
                    return
                (error) ->
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @addObjectID = ->
            DialogFactory.addID
                type: 'object'
                item: @lastObject
            .then(
                (result) =>
                    @lastObject.id = result.newIDs
                    return
                (error) ->
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @updateSupplies = ->
            DialogFactory.updateDescription
                type: 'supplies'
                item: @lastSupplies
            .then(
                (result) =>
                    @lastSupplies.description = result.newDescription
                    return
                (error) ->
                    return
            )
            .finally(
                =>
                    @resetInputField()
                    return
            )
            return

        @updateInventory = ->
            DialogFactory.updateInventory
                item: @lastSupplies
            .then(
                (result) =>
                    @lastSupplies.inventory = result.newInventory
                    return
                (error) ->
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
