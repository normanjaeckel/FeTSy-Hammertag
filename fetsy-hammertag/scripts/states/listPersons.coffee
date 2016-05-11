angular.module 'FeTSy-Hammertag.states.listPersons', [
    'FeTSy-Hammertag.utils.updateDescription'
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'UpdateDescriptionFactory'
    ($http, serverURL, UpdateDescriptionFactory) ->
        @unknownPersonID = 'Unknown'

        $http.get "#{serverURL}/all"
        .then(
            (response) =>
                @persons = []
                angular.forEach response.data, (data, personID) =>
                    data.ID = personID
                    @persons.push data
                    return
                return
        )

        @updatePerson = (person) ->
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

        @updateObject = (object) ->
            UpdateDescriptionFactory.update
                type: 'object'
                ID: object.ID
                description: object.description
            .then(
                (newDescription) ->
                    object.description = newDescription
                    return
            )
            return

        @removeObject = (object, objects, index) ->
            $http.delete "#{serverURL}/object/#{object.ID}"
            .then(
                (response) ->
                    objects.splice index, 1
                    return
            )
            return

        return
]
