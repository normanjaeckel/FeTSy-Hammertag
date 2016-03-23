angular.module 'FeTSy-Hammertag.states.listObjects', [
    'FeTSy-Hammertag.utils.personUpdate'
]


.controller 'ListObjectsCtrl', [
    '$http'
    'serverURL'
    'PersonUpdateFactory'
    ($http, serverURL, PersonUpdateFactory) ->
        $http.get "#{serverURL}/object"
        .then(
            (response) =>
                @objects = response.data
                return
        )

        @updatePerson = (objectID, personID) ->
            PersonUpdateFactory.update
                personID: personID
                personDescription: @objects[objectID].personDescription
            .then(
                (newPersonDescription) =>
                    @objects[objectID].personDescription = newPersonDescription
                    return
            )
            return

        @remove = (objectID) ->
            $http.delete "#{serverURL}/object/#{objectID}"
            .then(
                (response) =>
                    delete @objects[objectID]
                    return
            )
            return
        return
]
