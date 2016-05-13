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

        @updatePerson = (person , persons, index) ->
            UpdateDescriptionFactory.update
                type: 'person'
                ID: person.ID
                description: person.description
                withDelete: not person.objects.length and not person.supplies.length
            .then(
                (result) ->
                    if result.deleted
                        persons.splice index, 1
                    else
                        person.description = result.newDescription
                    return
            )
            return

        @updateObject = (object, objects, index) ->
            UpdateDescriptionFactory.update
                type: 'object'
                ID: object.ID
                description: object.description
                withDelete: true
            .then(
                (result) ->
                    if result.deleted
                        objects.splice index, 1
                    else
                        object.description = result.newDescription
                    return
            )
            return

        @updateSupplies = (supplies, allSupplies, index) ->
            UpdateDescriptionFactory.update
                type: 'supplies'
                ID: supplies.ID
                description: supplies.description
                itemUUID: supplies.itemUUID
                withDelete: true
            .then(
                (result) ->
                    if result.deleted
                        allSupplies.splice index, 1
                    else
                        supplies.description = result.newDescription
                    return
            )
            return

        return
]
