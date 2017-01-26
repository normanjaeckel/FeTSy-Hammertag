angular.module 'FeTSy-Hammertag.utils.updateInventory', []


.factory 'UpdateInventoryFactory', [
    '$uibModal'
    ($uibModal) ->
        update: (element) ->
            $uibModal.open
                controller: 'UpdateInventoryCtrl as updateInventory'
                templateUrl: 'static/templates/updateInventory.html'
                keyboard: false
                resolve:
                    element: () ->
                        element
            .result
]


.controller 'UpdateInventoryCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'element'
    ($http, $uibModalInstance, serverURL, element) ->
        @element = element
        @focus = true
        @save = ->
            if @element.inventory?
                data =
                    inventory: @element.inventory
                $http.patch "#{serverURL}/supplies/#{@element.id}", data
                .then(
                    (response) =>
                        $uibModalInstance.close
                            newInventory: @element.inventory
                        return
                )
            return
        return
]
