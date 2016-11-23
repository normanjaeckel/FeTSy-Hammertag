angular.module 'FeTSy-Hammertag.states.listPersons', [
    'angularMoment'
    'angularSpinner'
    'frapontillo.bootstrap-switch'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.updateDescription'
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'DefaultDescription'
    'UnknownPersonId'
    'UpdateDescriptionFactory'
    ($http, serverURL, DefaultDescription, UnknownPersonId, UpdateDescriptionFactory) ->
        @UnknownPersonId = UnknownPersonId

        @DefaultDescription = DefaultDescription

        @showObjects = true

        @showSupplies = false

        $http.get "#{serverURL}/person"
        .then (response) =>
            @persons = response.data.persons
            return

        @updatePerson = (person , persons) ->
            index = persons.indexOf person
            withDelete = not person.objects?.length and not person.supplies?.length
            UpdateDescriptionFactory.update
                type: 'person'
                id: person.id
                description: person.description
                withDelete: withDelete
            .then (result) ->
                if result.deleted
                    persons.splice index, 1
                else
                    person.description = result.newDescription
                return
            return

        @updateObject = (object, objects) ->
            index = objects.indexOf object
            UpdateDescriptionFactory.update
                type: 'object'
                id: object.id
                description: object.description
                withDelete: true
            .then (result) ->
                if result.deleted
                    objects.splice index, 1
                else
                    object.description = result.newDescription
                return
            return

        @updateSupplies = (supplies, allSupplies) ->
            index = allSupplies.indexOf supplies
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
