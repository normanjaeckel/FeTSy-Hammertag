angular.module 'FeTSy-Hammertag.states.listPersons', [
    'angular.filter'
    'angularMoment'
    'angularSpinner'
    'frapontillo.bootstrap-switch'
    'ngCookies'
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


.filter 'suppliesLimitTo', [
    ->
        (value, params) ->
            result = []
            if value?
                for i in _.keys value
                    result.push value[i]
                result = result.slice 0, params
            result
]


.controller 'ListPersonsCtrl', [
    '$cookies'
    '$filter'
    '$http'
    'cookieName'
    'serverURL'
    'DefaultDescription'
    'DialogFactory'
    'ItemInformationFactory'
    'UnknownPersonId'
    ($cookies, $filter, $http, cookieName, serverURL, DefaultDescription,
     DialogFactory, ItemInformationFactory, UnknownPersonId) ->
        @UnknownPersonId = UnknownPersonId

        @DefaultDescription = DefaultDescription

        # Load UI config from cookie

        cookie = $cookies.getObject(cookieName) or {}

        @showObjects = if cookie.showObjects? then cookie.showObjects else true

        # coffeelint: disable=max_line_length
        @showSupplies = if cookie.showSupplies? then cookie.showSupplies else true

        @searchFilterObjectsSuppliesEnabled = Boolean cookie.searchFilterObjectsSuppliesEnabled
        # coffeelint: enable=max_line_length

        @limit = cookie.limit or 50


        # Setup controller methods

        @toogleSearchFilterObjectsSupplies = ->
            # coffeelint: disable=max_line_length
            @searchFilterObjectsSuppliesEnabled = not @searchFilterObjectsSuppliesEnabled
            # coffeelint: enable=max_line_length
            @updateCookie()
            return

        @resetSearchFilter = ->
            @searchFilter = ''
            @searchFilterFocus = true
            return

        @resetSearchFilter()

        @limitStep = 50

        @decreaseLimit = ->
            if @limit > @limitStep
                @limit -= @limitStep
                @updateCookie()
            return

        @increaseLimit = ->
            @limit += @limitStep
            @updateCookie()
            return

        @updateCookie = ->
            $cookies.putObject cookieName,
                showObjects: @showObjects
                showSupplies: @showSupplies
                limit: @limit
                # coffeelint: disable=max_line_length
                searchFilterObjectsSuppliesEnabled: @searchFilterObjectsSuppliesEnabled
                # coffeelint: enable=max_line_length
            return


        # Fetch and handle data

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

        @numberOfSuppliesItems = (person) ->
            if person.supplies?
                filterInitialized = $filter 'objectsSuppliesFilter'
                filteredSupplies = filterInitialized(person.supplies,
                    expression: @searchFilter
                    enabled: @searchFilterObjectsSuppliesEnabled
                )
                _.size _.groupBy filteredSupplies, 'id'
            else
                0

        return
]
