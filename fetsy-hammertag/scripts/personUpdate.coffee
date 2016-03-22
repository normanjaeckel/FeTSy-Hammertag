angular.module 'FeTSy-Hammertag.personUpdate', []

.factory 'PersonUpdateFactory', [
    '$uibModal'
    ($uibModal) ->
        update: (person) ->
            if person.personDescription is 'Unknown'
                person.personDescription = ''
            $uibModal.open
                controller: 'PersonUpdateCtrl as personUpdate'
                templateUrl: 'static/templates/personUpdate.html'
                resolve:
                    person: () ->
                        person
            .result
]

.controller 'PersonUpdateCtrl', [
    '$http'
    '$uibModalInstance'
    'serverURL'
    'person'
    ($http, $uibModalInstance, serverURL, person) ->
        @person = person
        @focus = true
        @save = ->
            if @person.personDescription
                $http.patch "#{serverURL}/person/#{@person.personID}",
                    personDescription: @person.personDescription
                .then(
                    (response) =>
                        $uibModalInstance.close @person.personDescription
                        return
                )
            return
        return
]
