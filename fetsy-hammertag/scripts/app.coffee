angular.module 'FeTSy-Hammertag', [
    'ui.router'
    'FeTSy-Hammertag.controllers'
    'FeTSy-Hammertag.services'
]

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
