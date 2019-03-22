describe 'ExportCtrl', ->
    $httpBackend = undefined
    ExportCtrl = undefined
    DefaultDescription = undefined
    serverURL = undefined

    beforeEach ->
        module 'FeTSy-Hammertag', ($urlRouterProvider) ->
            $urlRouterProvider.deferIntercept()
        inject ($controller, $injector, _DefaultDescription_, _serverURL_) ->
            ExportCtrl = $controller 'ExportCtrl'
            $httpBackend = $injector.get '$httpBackend'
            DefaultDescription = _DefaultDescription_
            serverURL = _serverURL_

    describe 'calcMaxIDs', ->
        it 'should return number of ids of the element with most ids', ->
            elements = [
                description: 'description_ce4eC7bait'
                id: [
                    '42'
                    '43'
                ]
            ,
                description: 'description_go9zig6Jo9'
                id: [
                    '42'
                    '43'
                    '44'
                ]
            ,
                description: 'description_eer4cuth0Z'
                id: [
                    '42'
                ]
            ]
            expect ExportCtrl.calcMaxIDs elements
            .toBe 3

    describe 'parseObjectResponseData', ->
        testData = [
            id: ['42']
            description: 'description_Wae6Ooz6fi'
        ]
        it 'should return proper CSV data', ->
            parsedData = ExportCtrl.parseObjectResponseData testData
            expect parsedData
            .toContain 'data:text/csv;charset=utf-8,description,id'
            expect parsedData
            .toContain 'description_Wae6Ooz6fi,42'
            expect parsedData
            .not.toContain 'inventory'

    describe 'parseSuppliesResponseData', ->
        testData = [
            id: '42'
            description: 'description_eephoF3taM'
            inventory: 13
        ]
        it 'should return proper CSV data with inventory header and data', ->
            parsedData = ExportCtrl.parseSuppliesResponseData testData
            expect parsedData
            .toContain 'data:text/csv;charset=utf-8,id,description,inventory'
            expect parsedData
            .toContain '42,description_eephoF3taM,13'
            expect parsedData

    describe 'parseObjectResponseData', ->
        testData = [
            id: ['42']
            description: 'description_rao1ahFa3e'
            persons: [
                id: '13'
                description: 'desciption_xahKoo7Nuf'
                timestamp: 0
            ,
                id: '14'
                timestamp: 1374321600

            ]
        ]
        it 'should return CSV data with proper person columns', ->
            parsedData = ExportCtrl.parseObjectResponseData testData
            date = moment(1374321600000).format('YYYY-MM-DD HH:mm')
            person_1 = 'person_1_id,person_1_description,person_1_timestamp'
            person_2 = 'person_2_id,person_2_description,person_2_timestamp'
            expect parsedData
            .toContain "description,id,#{person_1},#{person_2}"
            expect parsedData
            .not.toContain 'person_3'
            expect parsedData
            .toContain '13,desciption_xahKoo7Nuf,1970-01-01'
            expect parsedData
            .toContain '14,' + DefaultDescription.person + ',' + date

    describe 'promisses', ->
        beforeEach ->
            $httpBackend.expectGET "#{serverURL}/config"
            .respond
                header: 'Example header daiQuize5uizuuShu7ig'
                welcomeText: 'Example welcome text IeS4yahKofitac3veic0'
            $httpBackend.expectGET "#{serverURL}/person"
            .respond
                persons: [
                    id: ['42', '46']
                    description: 'description_Shaeg4nahm'
                ]
            $httpBackend.expectGET "#{serverURL}/object"
            .respond
                objects: [
                    id: ['13', '133']
                    description: 'description_oobahGhoo5'
                ]
            $httpBackend.expectGET "#{serverURL}/supplies"
            .respond
                supplies: [
                    id: '14'
                    description: 'description_Oogh2ahshi'
                ]
        afterEach ->
            $httpBackend.verifyNoOutstandingExpectation()
            $httpBackend.verifyNoOutstandingRequest()
        it 'should fetch data from server and provide persons, objects and ' +
                'supplies property', ->
            expect ExportCtrl.persons
            .not.toBeDefined()
            expect ExportCtrl.objects
            .not.toBeDefined()
            expect ExportCtrl.supplies
            .not.toBeDefined()
            $httpBackend.flush()
            expect ExportCtrl.persons.URI
            .toContain 'data:text/csv;charset=utf-8,description,company,id,id_2'
            expect ExportCtrl.objects.URI
            .toContain 'data:text/csv;charset=utf-8,description,id,id_2'
            expect ExportCtrl.supplies.URI
            .toContain 'data:text/csv;charset=utf-8,id,description,inventory'
