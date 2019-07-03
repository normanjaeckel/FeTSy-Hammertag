angular.module 'FeTSy-Hammertag.utils.dialog', [
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.validation'
]


.factory 'DialogFactory', [
    '$uibModal'
    ($uibModal) ->
        updateDescription: (element) ->
            element = @parseElement element
            $uibModal.open
                controller: 'UpdateDescriptionCtrl as updateDescription'
                templateUrl: 'static/templates/updateDescription.html'
                resolve:
                    element: () ->
                        element
            .result

        updateInventory: (element) ->
            $uibModal.open
                controller: 'UpdateInventoryCtrl as updateInventory'
                templateUrl: 'static/templates/updateInventory.html'
                resolve:
                    element: () ->
                        element
            .result

        addID: (element) ->
            element = @parseElement element
            $uibModal.open
                controller: 'AddIDCtrl as addID'
                templateUrl: 'static/templates/addID.html'
                resolve:
                    element: () ->
                        element
            .result

        moreSupplies: (element) ->
            $uibModal.open
                controller: 'MoreSuppliesCtrl as moreSupplies'
                templateUrl: 'static/templates/moreSupplies.html'
                resolve:
                    element: () ->
                        element
            .result

        suppliesMaxCountInformation: (element) ->
            $uibModal.open
                # coffeelint: disable=max_line_length
                controller: 'SuppliesMaxCountInformationCtrl as suppliesMaxCountInformation'
                # coffeelint: enable=max_line_length
                templateUrl: 'static/templates/suppliesMaxCountInformation.html'
                resolve:
                    element: () ->
                        element
            .result

        unapplySupplies: (element) ->
            $uibModal.open
                controller: 'UnapplySuppliesCtrl as unapplySupplies'
                templateUrl: 'static/templates/unapplySupplies.html'
                resolve:
                    element: () ->
                        element
            .result

        parseElement: (element) ->
            if element.type is 'object'
                element.icon = 'glyphicon-wrench'
                element.label = 'Object'
            else if element.type is 'supplies'
                element.icon = 'glyphicon-tint'
                element.label = 'Supplies'
            else if element.type is 'person'
                element.icon = 'glyphicon-user'
                element.label = 'Person'
            else
                throw new Error 'Bad element type. Expected "object",
                    "supplies" or "person".'
            element
]


.controller 'UpdateDescriptionCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'element'
    ($http, $uibModalInstance, serverURL, element) ->
        @element = element
        @newDescription = element.item.description
        # The company field and the instruction field are only for persons.
        @newCompany = element.item.company
        @newInstruction = element.item.instruction
        # The instructionRequired field is only for objects.
        @newInstructionRequired = element.item.instructionRequired
        @focus = true

        @save = ->
            if @newDescription
                if element.type is 'supplies'
                    # Attention: @element.item.id is always a string and never
                    # an array at the moment.
                    url = "#{serverURL}/#{element.type}/#{@element.item.id}"
                else
                    url = "#{serverURL}/#{element.type}/#{@element.item.id[0]}"
                $http.patch url,
                    description: @newDescription
                    company: @newCompany
                    instruction: @newInstruction
                    instructionRequired: @newInstructionRequired
                .then(
                    (response) =>
                        $uibModalInstance.close
                            newDescription: @newDescription
                            newCompany: @newCompany
                            newInstruction: @newInstruction
                            newInstructionRequired: @newInstructionRequired
                        return
                    (error) =>
                        if error.data
                            @error = error.data.detail or 'Unknown error'
                        else
                            @error = 'Connection failed. Please reload the ' +
                                     'page.'
                        return
                )
            return

        @delete = ->
            if element.type is 'supplies'
                console.error 'Supplies can not be deleted here.'
            else
                url = "#{serverURL}/#{element.type}/#{element.item.id[0]}"
                promise = $http.delete url
            promise.then(
                (response) ->
                    $uibModalInstance.close
                        deleted: true
                    return
                (error) =>
                    if error.data
                        @error = error.data.detail or 'Unknown error'
                    else
                        @error = 'Connection failed. Please reload the page.'
                    return
            )
            return

        @clearNewCompanyField = ->
            @newCompany = ''
            return

        return
]


.controller 'UpdateInventoryCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'element'
    ($http, $uibModalInstance, serverURL, element) ->
        @element = element
        @newInventory = element.item.inventory or 0
        @focus = true
        @save = ->
            if not @newInventory?
                return
            # Attention: @element.item.id is always a string and never
            # an array at the moment.
            $http.patch "#{serverURL}/supplies/#{@element.item.id}",
                inventory: @newInventory
            .then(
                (response) =>
                    $uibModalInstance.close
                        newInventory: @newInventory
                    return
                (error) =>
                    if error.data
                        @error = error.data.detail or 'Unknown error'
                    else
                        @error = 'Connection failed. Please reload the page.'
                    return
            )
            return
        return
]


.controller 'AddIDCtrl', [
    '$http'
    '$uibModalInstance'
    'ValidationFactory'
    'serverURL'
    'element'
    ($http, $uibModalInstance, ValidationFactory, serverURL, element) ->
        @element = element
        @newID = ''
        @focus = true
        @save = ->
            if @element.type is ValidationFactory.validateInput @newID
                url = "#{serverURL}/#{element.type}/#{@element.item.id[0]}"
                $http.post url,
                    id: @newID
                .then(
                    (response) =>
                        element.item.id.push @newID
                        $uibModalInstance.close
                            newIDs: element.item.id
                        return
                    (error) =>
                        if error.data
                            @error = error.data.detail or 'Unknown error'
                        else
                            @error = 'Connection failed. Please reload the ' +
                                     'page.'
                        return
                )
            else
                @error = 'Invalid input. Please try again.'
            return
        @resetInputField = ->
            @newID = ''
            @error = false
            @focus = true
            return
        return
]


.controller 'SuppliesMaxCountInformationCtrl', [
    '$http'
    '$uibModalInstance'
    'DefaultDescription'
    'serverURL'
    'element'
    ($http, $uibModalInstance, DefaultDescription, serverURL, element) ->
        @DefaultDescription = DefaultDescription
        @element = element
        # Attention: We assume that there is only one element with matching id
        # but the code does not check it.
        @suppliesMaxCountElement = _.find(
            element.supplies.personMaxCount,
            (item) ->
                item.id in element.person.id
        )
        @reset = ->
            url = "#{serverURL}/supplies/#{element.supplies.id}/reset-max-count"
            $http.post url,
                personId: @suppliesMaxCountElement.id
            .then(
                (response) ->
                    $uibModalInstance.close
                        newMaxCount: response.data.maxCount
                    return
                (error) =>
                    if error.data
                        @error = error.data.detail or 'Unknown error'
                    else
                        @error = 'Connection failed. Please reload the page.'
                    return
            )
        return
]


.controller 'MoreSuppliesCtrl', [
    '$uibModalInstance'
    'DatabaseFactory'
    'element'
    ($uibModalInstance, DatabaseFactory, element) ->
        @element = element
        @numberField = 1
        @focus = true
        @save = ->
            if not @numberField?
                return
            DatabaseFactory.saveSupplies(
                @element.item.id
                @element.person
                @numberField
            ).then(
                (response) ->
                    $uibModalInstance.close
                        supplies: response.data.supplies
                    return
                (error) =>
                    if error.data
                        @error = error.data.detail or 'Unknown error'
                    else
                        @error = 'Connection failed. Please reload the page.'
                    return
            )
            return
        @resetNumberField = ->
            @numberField = 1
            @focus = true
            return
        return
]


.controller 'UnapplySuppliesCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'element'
    ($http, $uibModalInstance, serverURL, element) ->
        @element = element
        @numberField = 1
        @focus = true
        @save = ->
            if not @numberField?
                return
            filteredPersonItems = _.filter element.item.persons, (personItem) ->
                personItem.id in element.person.id
            uuidList = _.map _.takeRight(filteredPersonItems, @numberField),
                'uuid'
            # Attention: @element.item.id is always a string and never
            # an array at the moment.
            $http
                method: 'DELETE'
                url: "#{serverURL}/supplies/#{element.item.id}"
                headers:
                    'Content-Type': 'application/json;charset=utf-8'
                data:
                    uuidList: uuidList
            .then(
                (response) ->
                    $uibModalInstance.close
                        uuidList: uuidList
                    return
                (error) =>
                    if error.data
                        @error = error.data.detail or 'Unknown error'
                    else:
                        @error = 'Connection failed. Please reload the page.'
                    return
            )
            return
        @resetNumberField = ->
            @numberField = 1
            @focus = true
            return
        return
]
