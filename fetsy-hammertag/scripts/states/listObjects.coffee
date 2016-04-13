angular.module 'FeTSy-Hammertag.states.listObjects', [
    'FeTSy-Hammertag.utils.updateDescription'
]


.controller 'ListObjectsCtrl', [
    '$http'
    'serverURL'
    'UpdateDescriptionFactory'
    ($http, serverURL, UpdateDescriptionFactory) ->
        $http.get "#{serverURL}/object"
        .then(
            (response) =>
                @objects = response.data
                return
        )

        @updateObject = (objectID) ->
            UpdateDescriptionFactory.update
                type: 'object'
                ID: objectID
                description: @objects[objectID].objectDescription
            .then(
                (newDescription) =>
                    @objects[objectID].objectDescription = newDescription
                    return
            )
            return

        @updatePerson = (objectID, personID) ->
            UpdateDescriptionFactory.update
                type: 'person'
                ID: personID
                description: @objects[objectID].personDescription
            .then(
                (newDescription) =>
                    @objects[objectID].personDescription = newDescription
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
