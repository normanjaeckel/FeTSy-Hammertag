angular.module 'FeTSy-Hammertag.utils.objectUpdate', []

.factory 'ObjectUpdateFactory', [
    '$uibModal'
    ($uibModal) ->
        update: (object) ->
            if object.objectDescription is 'Unknown object'
                object.objectDescription = ''
            $uibModal.open
                controller: 'ObjectUpdateCtrl as objectUpdate'
                templateUrl: 'static/templates/objectUpdate.html'
                resolve:
                    object: () ->
                        object
            .result
]

.controller 'ObjectUpdateCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'object'
    ($http, $uibModalInstance, serverURL, object) ->
        @object = object
        @focus = true
        @save = ->
            if @object.objectDescription
                $http.patch "#{serverURL}/object/#{@object.objectID}",
                    objectDescription: @object.objectDescription
                .then(
                    (response) =>
                        $uibModalInstance.close @object.objectDescription
                        return
                )
            return
        return
]
