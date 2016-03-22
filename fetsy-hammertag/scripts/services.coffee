angular.module 'FeTSy-Hammertag.services', []

.constant 'serverURL', '/api'

.factory 'ScanInputValidationFactory', [
    () ->
        validateObject: (data) ->
            if not isNaN data
                parseInt data
            else
                null
        validatePerson: (data) ->
            data
]


# See: http://stackoverflow.com/questions/14833326/
#      how-to-set-focus-on-input-field

.directive 'focusMe', [
    '$parse'
    '$timeout'
    ($parse, $timeout) ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            model = $parse attrs.focusMe
            scope.$watch model, (value) ->
                if value is true
                    $timeout ->
                        element[0].focus()
                        return
                return
            element.bind 'blur', ->
                scope.$apply model.assign scope, false
            return
]
