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
            if not _.isArray value
                value = _.map value
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

        @suppliesCount = (supplies, personId) ->
            numbers = _.countBy supplies.persons, 'id'
            _.reduce(
                numbers
                (count, number, id) ->
                  if id in personId
                      number + count
                  else
                      count
                0
            )

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
                        person.instruction = result.newInstruction
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
                        # coffeelint: disable=max_line_length
                        object.instructionRequired = result.newInstructionRequired
                        # coffeelint: enable=max_line_length
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

        @suppliesMaxCountInformation = (supplies, person) ->
            index = _.findIndex supplies.personMaxCount, (element) ->
                element.id in person.id
            DialogFactory.suppliesMaxCountInformation
                supplies: supplies
                person: person
            .then(
                (result) ->
                    supplies.personMaxCount[index].maxCount = result.newMaxCount
                    return
                (error) ->
                    return
            )
            return

        @updateSupplies = (supplies, person) ->
            index = _.findLastIndex supplies.persons, (personItem) ->
                personItem.id in person.id
            DialogFactory.updateDescription
                type: 'supplies'
                item: supplies
                withDelete: false
            .then(
                (result) ->
                    if result.deleted
                        supplies.persons.splice index, 1
                    else
                        supplies.description = result.newDescription
                    return
                (error) ->
                    return
            )
            return

        @unapplySupplies = (supplies, person) ->
            DialogFactory.unapplySupplies
                item: supplies
                person: person
            .then(
                (result) ->
                    _.remove supplies.persons, (personItem) ->
                        personItem.uuid in result.uuidList
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
            else
                0

        return
]
