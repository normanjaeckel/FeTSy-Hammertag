angular.module 'FeTSy-Hammertag.controllers', []


.controller 'NavbarCtrl', [
    () ->
]


.controller 'ScanInputCtrl', [
    'ScanInputValidationFactory'
    (ScanInputValidationFactory) ->
        @focusScanObject = true
        @focusScanPerson = not @focusScanObject
        @saveObject = ->
            data = ScanInputValidationFactory.validateObject @scanObject
            if data
                @focusScanPerson = true
                @updateObject = true


        @savePerson = ->
            data = ScanInputValidationFactory.validatePerson @scanPerson
            if data
                console.log data
                @focusScanObject = true
        return
]


.controller 'UpdateObjectCtrl', [
    () ->
        @save = ->
            console.log 'save'
]
