angular.module 'FeTSy-Hammertag.utils.validation', []


.constant 'objectRegex', /^(HKES_\d{7}|\d{5}|\d{6})$/


.constant 'suppliesRegex', /^\d{13}$/


.constant 'personRegex', /^(\d{8}|\d{11})$/


.factory 'ValidationFactory', [
    'objectRegex'
    'suppliesRegex'
    'personRegex'
    (objectRegex, suppliesRegex, personRegex) ->
        validateInput: (data) ->
            switch
                when objectRegex.test data then 'object'
                when suppliesRegex.test data then 'supplies'
                when personRegex.test data then 'person'
                else null
]
