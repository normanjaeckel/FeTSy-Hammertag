angular.module 'FeTSy-Hammertag.utils.validation', []


.constant 'singleObjectRegex', /^HKES_\d{7}$/


.constant 'massObjectRegex', /^\d{13}$/


.constant 'personRegex', /^\d{8}$/


.factory 'ValidationFactory', [
    'singleObjectRegex'
    'massObjectRegex'
    'personRegex'
    (singleObjectRegex, massObjectRegex, personRegex) ->
        validateInput: (data) ->
            switch
                when singleObjectRegex.test data then 'singleObject'
                when massObjectRegex.test data then 'massObject'
                when personRegex.test data then 'person'
                else null
]
