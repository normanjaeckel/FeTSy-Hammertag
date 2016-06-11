angular.module 'FeTSy-Hammertag.utils.validation', []


.constant 'singleObjectRegex', /^(HKES_\d{7}|\d{5})$/


.constant 'suppliesRegex', /^(\d{13}|\d{6})$/


.constant 'personRegex', /^\d{8}$/


.factory 'ValidationFactory', [
    'singleObjectRegex'
    'suppliesRegex'
    'personRegex'
    (singleObjectRegex, suppliesRegex, personRegex) ->
        validateInput: (data) ->
            switch
                when singleObjectRegex.test data then 'singleObject'
                when suppliesRegex.test data then 'supplies'
                when personRegex.test data then 'person'
                else null
]
