angular.module 'FeTSy-Hammertag.states.listPersons', [
    'angular.filter'
    'angularMoment'
    'angularSpinner'
    'frapontillo.bootstrap-switch'
    'FeTSy-Hammertag.utils.contentDefaults'
    'FeTSy-Hammertag.utils.dialog'
    'FeTSy-Hammertag.utils.itemInformation'
]


.filter 'objectsSuppliesFilter', [
    '$filter'
    ($filter) ->
        (value, params) ->
            if params.enabled
                $filter('filter') value, params.expression
            else
                value
]


.controller 'ListPersonsCtrl', [
    '$http'
    'serverURL'
    'DefaultDescription'
    'DialogFactory'
    'ItemInformationFactory'
    'UnknownPersonId'
    ($http, serverURL, DefaultDescription, DialogFactory,
     ItemInformationFactory, UnknownPersonId) ->
        @UnknownPersonId = UnknownPersonId

        @DefaultDescription = DefaultDescription

        @showObjects = true

        @showSupplies = false

        @searchFilterObjectsSuppliesEnabled = false

        @toogleSearchFilterObjectsSupplies = ->
            @searchFilterObjectsSuppliesEnabled = not @searchFilterObjectsSuppliesEnabled

        @resetSearchFilter = ->
            @searchFilter = ''
            @searchFilterFocus = true
            return

        @resetSearchFilter()

        $http.get "#{serverURL}/person"
        .then (response) =>
            @persons = response.data.persons
            return

        @updatePerson = (person , persons) ->
            index = persons.indexOf person
            withDelete = not person.objects?.length and
                         not person.supplies?.length
            DialogFactory.updateDescription
                type: 'person'
                item: person
                withDelete: withDelete
            .then(
                (result) ->
                    if result.deleted
                        persons.splice index, 1
                    else
                        person.description = result.newDescription
                        person.company = result.newCompany
                    return
                (error) ->
                    return
            )
            return

        @objectInformation = (object) ->
            ItemInformationFactory.open
                type: 'object'
                id: object.id[0]
            .then(
                (result) ->
                    return
                (error) ->
                    return
            )
            return

        @updateObject = (object, objects) ->
            index = objects.indexOf object
            DialogFactory.updateDescription
                type: 'object'
                item: object
                withDelete: true
            .then(
                (result) ->
                    if result.deleted
                        objects.splice index, 1
                    else
                        object.description = result.newDescription
                    return
                (error) ->
                    return
            )
            return

        @suppliesInformation = (supplies) ->
            ItemInformationFactory.open
                type: 'supplies'
                id: supplies.id
            .then(
                (result) ->
                    return
                (error) ->
                    return
            )
            return

        @updateSupplies = (supplies, allSupplies) ->
            index = allSupplies.indexOf supplies
            DialogFactory.updateDescription
                type: 'supplies'
                item: supplies
                withDelete: true
            .then(
                (result) ->
                    if result.deleted
                        allSupplies.splice index, 1
                    else
                        supplies.description = result.newDescription
                    return
                (error) ->
                    return
            )
            return

        return
]
