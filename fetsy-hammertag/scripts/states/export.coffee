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

                angular.forEach response.data, (data, personID) =>
                    # Care of redundancy with server
                    unknownPersonID = 'Unknown'

                    # Catch persons
                    if personID isnt unknownPersonID
                        @persons.push
                            ID: personID
                            Description: data.description

                    # Catch objects
                    angular.forEach data.objects, (object) =>
                        @objects.push
                            ID: object.ID
                            Description: object.description
                            PersonID: personID
                            PersonDescription: data.description
                        return

                    # Catch supplies
                    angular.forEach data.supplies, (supplies) =>
                        if not @suppliesObj[supplies.ID]?
                            @suppliesObj[supplies.ID] =
                                ID: supplies.ID
                                description: supplies.description
                                persons: []
                        @suppliesObj[supplies.ID].persons.push personID
                        return
                    return

                # Parse supplies
                @supplies = []
                angular.forEach @suppliesObj, (supplies, suppliesID) =>
                    item =
                        ID: suppliesID
                        Description: supplies.description
                    angular.forEach supplies.persons, (personID, index) ->
                        item["Person#{index + 1}"] = personID
                        return
                    @supplies.push item
                    return

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
