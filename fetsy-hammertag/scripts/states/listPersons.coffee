angular.module 'FeTSy-Hammertag.states.listPersons', [
    'FeTSy-Hammertag.utils.updateDescription'
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'UpdateDescriptionFactory'
    ($http, serverURL, UpdateDescriptionFactory) ->
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
            UpdateDescriptionFactory.update
                type: 'person'
                ID: person.ID
                description: person.description
            .then(
                (newDescription) ->
                    person.description = newDescription
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
