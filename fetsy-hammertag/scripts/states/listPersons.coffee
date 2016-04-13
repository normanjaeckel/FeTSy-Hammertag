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
                @persons = []
                angular.forEach response.data, (personDescription, personID) =>
                    @persons.push
                        ID: personID
                        description: personDescription
                    return
                return
        )

        @update = (person) ->
            PersonUpdateFactory.update
                personID: person.ID
                personDescription: person.description
            .then(
                (newPersonDescription) =>
                    person.description = newPersonDescription
                    return
            )
            return

        @remove = (person, index) ->
            $http.delete "#{serverURL}/person/#{person.ID}"
            .then(
                (response) =>
                    @persons.splice index, 1
                    return
            )
            return
        return
]
