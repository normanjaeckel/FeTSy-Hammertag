angular.module 'FeTSy-Hammertag.states.export', []


.controller 'ExportCtrl', [
    '$http'
    'serverURL'
    ($http, serverURL) ->
        $http.get "#{serverURL}/all"
        .then(
            (response) =>
                @persons = []
                @objects = []
                @suppliesObj = {}
                maxPersons = 0

                # Parse response.data
                for personID, data of response.data
                    # Care of redundancy with server
                    unknownPersonID = 'Unknown'

                    # Catch persons
                    if personID isnt unknownPersonID
                        @persons.push
                            ID: personID
                            Description: data.description

                    # Catch objects
                    for object in data.objects
                        @objects.push
                            ID: object.ID
                            Description: object.description
                            PersonID: personID
                            PersonDescription: data.description

                    # Catch supplies
                    for supplies in data.supplies
                        if not @suppliesObj[supplies.ID]?
                            @suppliesObj[supplies.ID] =
                                ID: supplies.ID
                                description: supplies.description
                                persons: []
                        if personID isnt unknownPersonID
                            @suppliesObj[supplies.ID].persons.push
                                ID: personID
                                description: data.description
                            if maxPersons < @suppliesObj[supplies.ID].persons.length
                                maxPersons = @suppliesObj[supplies.ID].persons.length

                # Parse supplies
                @supplies =
                    fields: ['ID', 'Description']
                    data: []
                @supplies.fields.push "Person#{num}" for num in [1..maxPersons]
                for suppliesID, supplies of @suppliesObj
                    item = [suppliesID, supplies.description]
                    item.push "#{person.description} (#{person.ID})" for person in supplies.persons
                    @supplies.data.push item

                # Create CSV output
                @persons = 'data:text/csv;charset=utf-8,' + Papa.unparse @persons
                @persons = encodeURI @persons
                @objects = 'data:text/csv;charset=utf-8,' + Papa.unparse @objects
                @objects = encodeURI @objects
                @supplies = 'data:text/csv;charset=utf-8,' + Papa.unparse @supplies
                @supplies = encodeURI @supplies

                return
        )
        return
]
