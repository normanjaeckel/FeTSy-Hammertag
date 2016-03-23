
angular.module 'FeTSy-Hammertag.states.listPersons', [
    'FeTSy-Hammertag.utils.personUpdate'
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'PersonUpdateFactory'
    ($http, serverURL, PersonUpdateFactory) ->
        $http.get "#{serverURL}/person"
        .then(
            (response) =>
                @persons = response.data
                return
        )

        @update = (personID) ->
            PersonUpdateFactory.update
                personID: personID
                personDescription: @persons[personID]
            .then(
                (newPersonDescription) =>
                    @persons[personID] = newPersonDescription
                    return
            )
            return

        @remove = (personID) ->
            $http.delete "#{serverURL}/person/#{personID}"
            .then(
                (response) =>
                    delete @persons[personID]
                    return
            )
            return
        return
]
