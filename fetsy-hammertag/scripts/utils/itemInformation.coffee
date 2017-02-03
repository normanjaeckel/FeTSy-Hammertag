angular.module 'FeTSy-Hammertag.utils.itemInformation', []


.factory 'ItemInformationFactory', [
    '$uibModal'
    ($uibModal) ->
        open: (element) ->
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
            $uibModal.open
                controller: 'ItemInformationCtrl as itemInformation'
                templateUrl: 'static/templates/itemInformation.html'
                keyboard: false
                resolve:
                    element: () ->
                        element
            return
]
