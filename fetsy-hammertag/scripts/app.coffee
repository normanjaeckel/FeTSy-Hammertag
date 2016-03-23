angular.module 'FeTSy-Hammertag', [
    'ui.bootstrap'
    'ui.router'
    'FeTSy-Hammertag.states'
]


.constant 'serverURL', '/api'


.config [
    '$locationProvider'
    '$stateProvider'
    '$urlRouterProvider'
    ($locationProvider, $stateProvider, $urlRouterProvider) ->

        # Uses HTML5 mode for location in browser address bar
        $locationProvider.html5Mode true

        # For any unmatched url, redirect to /
        $urlRouterProvider.otherwise '/'

        # Set up the states
        $stateProvider
        .state  'scanInput',
            url: '/'
            templateUrl: 'static/templates/scanInput.html'
            controller: 'ScanInputCtrl as scanInput'

        .state  'listObjects',
            url: '/list/objects'
            templateUrl: 'static/templates/listObjects.html'
            controller: 'ListObjectsCtrl as listObjects'

        .state  'listPersons',
            url: '/list/persons'
            templateUrl: 'static/templates/listPersons.html'
            controller: 'ListPersonsCtrl as listPersons'

        return
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


.controller 'NavbarCtrl', [
    () ->
]
