angular.module 'FeTSy-Hammertag.states.scanSingleObject', [
    'angularMoment'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.database'
    'FeTSy-Hammertag.utils.dialog'
    'FeTSy-Hammertag.utils.validation'
]


.controller 'ScanSingleObjectCtrl', [
    '$stateParams'
    '$scope'
    'DatabaseFactory'
    'DefaultDescription'
    'DialogFactory'
    'ValidationFactory'
    ($stateParams, $scope, DatabaseFactory, DefaultDescription, DialogFactory,
     ValidationFactory) ->
        @DefaultDescription = DefaultDescription

        @scan = =>
            errorHandling = (response) =>
                @scanInputValue = ''
                @focusScanInput = true
                if response.data
                    @error = response.data.detail.message
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
                            if not @lastPerson.description?
                                @updatePersonDescription()
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
                                if not @lastObject.description?
                                    @updateObjectDescription()
                                return
                            errorHandling
                        )
                    else
                        @scanInputValue = ''
                        # coffeelint: disable=max_line_length
                        @error = 'Unknown person. Description and company missing.'
                        # coffeelint: enable=max_line_length
                else
                    DatabaseFactory.fetchObject(@scanInputValue)
                    .then(
                        (response) =>
                            @lastObject = response.data.object
                            @resetInputField()
                            if not @lastObject.description?
                                @updateObjectDescription()
                            return
                        errorHandling
                    )
            else if type is 'supplies'
                @lastObject = null
                if @lastPerson
                    if @lastPerson.description?
                        DialogFactory.askForAmount
                            scanInputValue: @scanInputValue
                        .then(
                            (result) =>
                                DatabaseFactory.saveSupplies(
                                    @scanInputValue
                                    _.last @lastPerson.id
                                    result.amount
                                ).then(
                                    (response) =>
                                        @lastSupplies = response.data.supplies
                                        @resetInputField()
                                        if not @lastSupplies.description?
                                            @updateSupplies()
                                        return
                                    errorHandling
                                )
                            (error) ->
                                return
                        )
                    else
                        @scanInputValue = ''
                        # coffeelint: disable=max_line_length
                        @error = 'Unknown person. Description and company missing.'
                        # coffeelint: enable=max_line_length

                else
                    DatabaseFactory.fetchSupplies(@scanInputValue)
                    .then(
                        (response) =>
                            if not response.data.supplies.persons?
                                response.data.supplies.persons = []
                            @lastSupplies = response.data.supplies
                            @resetInputField()
                            if not @lastSupplies.description?
                                @updateSupplies()
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
                    @lastPerson.company = result.newCompany
                    @lastPerson.instruction = result.newInstruction
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
                    # coffeelint: disable=max_line_length
                    @lastObject.instructionRequired = result.newInstructionRequired
                    # coffeelint: enable=max_line_length
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

        @suppliesLabel = ->
            if @lastSupplies?
                out = @lastSupplies.persons.length
                (@lastSupplies.inventory or 0) - out <= 0

        @moreSupplies = ->
            DialogFactory.moreSupplies
                item: @lastSupplies
                person: _.last @lastPerson.id
            .then(
                (result) =>
                    @lastSupplies = result.supplies
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

        if $stateParams.scanInputValue
          @scanInputValue = $stateParams.scanInputValue
          @scan()

        $scope.$on 'IdleStart', ->
            @resetForm()
            return

        return
]
