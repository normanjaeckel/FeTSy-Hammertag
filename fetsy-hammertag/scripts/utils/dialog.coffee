angular.module 'FeTSy-Hammertag.utils.dialog', [
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
        # The company field is only for persons.
        @newCompany = element.item.company
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
                .then(
                    (response) =>
                        $uibModalInstance.close
                            newDescription: @newDescription
                            newCompany: @newCompany
                        return
                )
            return
        @delete = ->
            if element.type is 'supplies'
                # Attention: @element.item.id is always a string and never
                # an array at the moment.
                promise = $http
                    method: 'DELETE'
                    url: "#{serverURL}/supplies/#{element.item.id}"
                    headers:
                        'Content-Type': 'application/json;charset=utf-8'
                    data:
                        uuid: element.item.uuid
            else
                url = "#{serverURL}/#{element.type}/#{element.item.id[0]}"
                promise = $http.delete url
            promise.then(
                (response) ->
                    $uibModalInstance.close
                        deleted: true
                    return
            )
            return
        @resetNewCompanyField = ->
            #TODO ###################################################################
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
            # Attention: @element.item.id is always a string and never
            # an array at the moment.
            $http.patch "#{serverURL}/supplies/#{@element.item.id}",
                inventory: @newInventory
            .then(
                (response) =>
                    $uibModalInstance.close
                        newInventory: @newInventory
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
                        @error = true
                        return
                )
            else
                @error = true
            return
        @resetInputField = ->
            @newID = ''
            @error = false
            @focus = true
            return
        return
]
