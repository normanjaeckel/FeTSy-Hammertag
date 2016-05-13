angular.module 'FeTSy-Hammertag.utils.updateDescription', []


.factory 'UpdateDescriptionFactory', [
    '$uibModal'
    ($uibModal) ->
        update: (element) ->
            if element.type is 'object'
                if element.description is 'Unknown object'
                    element.description = ''
                element.icon = 'glyphicon-wrench'
                element.label = 'Object'
            else if element.type is 'supplies'
                if element.description is 'Unknown'
                    element.description = ''
                element.icon = 'glyphicon-tint'
                element.label = 'Supplies'
            else if element.type is 'person'
                if element.description is 'Unknown'
                    element.description = ''
                element.icon = 'glyphicon-user'
                element.label = 'Person'
            else
                throw new Error 'Bad element type. Expected "object",
                    "supplies" or "person".'
            $uibModal.open
                controller: 'UpdateDescriptionCtrl as updateDescription'
                templateUrl: 'static/templates/updateDescription.html'
                keyboard: false
                resolve:
                    element: () ->
                        element
            .result
]


.controller 'UpdateDescriptionCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'element'
    ($http, $uibModalInstance, serverURL, element) ->
        @element = element
        @focus = true
        @withDelete = element.withDelete
        @save = ->
            if @element.description
                if element.type is 'object'
                    data =
                        objectDescription: @element.description
                else if element.type is 'supplies'
                    data =
                        suppliesDescription: @element.description
                else if element.type is 'person'
                    data =
                        personDescription: @element.description
                $http.patch "#{serverURL}/#{element.type}/#{@element.ID}", data
                .then(
                    (response) =>
                        $uibModalInstance.close
                            newDescription: @element.description
                        return
                )
            return
        @delete = ->
            if element.type is 'supplies'
                promise = $http
                    method: 'DELETE'
                    url: "#{serverURL}/supplies/#{element.ID}"
                    headers:
                        'Content-Type': 'application/json;charset=utf-8'
                    data:
                        itemUUID: element.itemUUID
            else
                promise = $http.delete "#{serverURL}/#{element.type}/#{element.ID}"
            promise.then(
                (response) ->
                    $uibModalInstance.close
                        deleted: true
                    return
            )
            return
        return
]
