angular.module 'FeTSy-Hammertag.utils.itemInformation', [
    'angularMoment'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.database'
]


.factory 'ItemInformationFactory', [
    '$uibModal'
    'DatabaseFactory'
    ($uibModal, DatabaseFactory) ->
        open: (element) ->
            if element.type is 'object'
                element.icon = 'glyphicon-wrench'
                element.label = 'Object'
                elementResolver = () ->
                    DatabaseFactory.fetchObject element.id
                    .then(
                        (response) ->
                            _.assign element, response.data.object
                        (response) ->
                            if response.data
                                element.error = response.data.details
                            else
                                element.error = 'Connection failed. Please ' +
                                    'reload the page.'
                            element
                    )
            else if element.type is 'supplies'
                element.icon = 'glyphicon-tint'
                element.label = 'Supplies'
                elementResolver = () ->
                    DatabaseFactory.fetchSupplies element.id
                    .then(
                        (response) ->
                            _.assign element, response.data.supplies
                        (response) ->
                            if response.data
                                element.error = response.data.details
                            else
                                element.error = 'Connection failed. Please ' +
                                    'reload the page.'
                            element
                    )
            else
                throw new Error 'Bad element type. Expected "object",
                    "supplies" or "person".'
            $uibModal.open
                controller: 'ItemInformationCtrl as itemInformation'
                templateUrl: 'static/templates/itemInformation.html'
                resolve:
                    element: elementResolver
            .result
]


.controller 'ItemInformationCtrl', [
    'DefaultDescription'
    'element'
    (DefaultDescription, element) ->
        @DefaultDescription = DefaultDescription
        @element = element
        return
]
