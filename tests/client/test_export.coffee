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

    describe 'parseResponseData', ->
        testData = [
            id: '42'
            description: 'description_Wae6Ooz6fi'
            inventory: 13
        ]
        it 'should return data with inventory header and data', ->
            parsedData = ExportCtrl.parseResponseData testData, true
            expect parsedData
            .toContain 'data:text/csv;charset=utf-8,id,description,inventory'
            expect parsedData
            .toContain '42,description_Wae6Ooz6fi,13'
        it 'should return data without inventory header and data', ->
            parsedData = ExportCtrl.parseResponseData testData, false
            expect parsedData
            .toContain 'data:text/csv;charset=utf-8,id,description'
            expect parsedData
            .toContain '42,description_Wae6Ooz6fi'
            expect parsedData
            .not.toContain 'inventory'
            expect parsedData
            .not.toContain '13'

    describe 'parseResponseData', ->
        testData = [
            id: '42'
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
        it 'should return CSV data with proper person cells', ->
            parsedData = ExportCtrl.parseResponseData testData, false
            date = new Date(1374321600000).toLocaleFormat '%Y-%m-%d %H:%M'
            expect parsedData
            .toContain 'id,description,person_1,person_2'
            expect parsedData
            .not.toContain 'person_3'
            expect parsedData
            .toContain encodeURI '13 · desciption_xahKoo7Nuf · 1970-01-01'
            expect parsedData
            .toContain encodeURI(
                '14 · ' + DefaultDescription.person + ' · ' + date
            )

    describe 'promisses', ->
        beforeEach ->
            $httpBackend.expectGET "#{serverURL}/person"
            .respond
                persons: [
                    id: '42'
                    description: 'description_Shaeg4nahm'
                ]
            $httpBackend.expectGET "#{serverURL}/object"
            .respond
                objects: [
                    id: '13'
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
            .toContain 'data:text/csv;charset=utf-8,id,description'
            expect ExportCtrl.objects.URI
            .toContain 'data:text/csv;charset=utf-8,id,description'
            expect ExportCtrl.supplies.URI
            .toContain 'data:text/csv;charset=utf-8,id,description,inventory'
