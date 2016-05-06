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
            else
                if element.description is 'Unknown'
                    element.description = ''
                element.icon = 'glyphicon-user'
                element.label = 'Person'
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
        @save = ->
            if @element.description
                if element.type is 'object'
                    data =
                        objectDescription: @element.description
                else
                    data =
                        personDescription: @element.description
                $http.patch "#{serverURL}/#{element.type}/#{@element.ID}", data
                .then(
                    (response) =>
                        $uibModalInstance.close @element.description
                        return
                )
            return
        return
]
