angular.module 'FeTSy-Hammertag.states.listPersons', [
    'frapontillo.bootstrap-switch'
    'FeTSy-Hammertag.utils.updateDescription'
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'UpdateDescriptionFactory'
    ($http, serverURL, UpdateDescriptionFactory) ->
        @unknownPersonID = 'Unknown'

        @showObjects = true

        @showSupplies = false

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

        @updateSupplies = (supplies) ->
            UpdateDescriptionFactory.update
                type: 'supplies'
                ID: supplies.ID
                description: supplies.description
            .then(
                (newDescription) ->
                    supplies.description = newDescription
                    return
            )
            return

        @removeSupplies = (supplies, allSupplies, index) ->
            $http
                method: 'DELETE'
                url: "#{serverURL}/supplies/#{supplies.ID}"
                headers:
                    'Content-Type': 'application/json;charset=utf-8'
                data:
                    itemUUID: supplies.itemUUID
            .then(
                (response) ->
                    allSupplies.splice index, 1
                    return
            )
            return

        return
]
