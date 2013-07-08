# #### VALIDATORS AND TRANSFORMATIONS #########
boolean = (x) -> 
    if Meteor.isClient
        x
    else
        if not (typeof x == 'boolean')
            if x is null
                return x
            throw "The value must be a boolean"
        x
    
string = (x) -> 
    if Meteor.isClient
        x
    else
        if not (typeof x == 'string')
            throw "The value must be a string"
        x

text = (x) -> 
    if Meteor.isClient
        x
    else
        if not (typeof x == 'string')
            throw "The value must be a string"
        x

 
nested = (klass) ->
    klass: klass

nested_array = (klass) ->
    klass: klass     

string_array = (x) ->
    if Meteor.isClient
        x.split('\n')
    else
        if not _.isArray(x)
            throw 'Value must be an array'
        for v in x
            if not (typeof v == 'string')
                throw 'Value must be an array of strings'
        x

date = (format) ->
    (x) ->
        if Meteor.isClient
            console.log(x, format)
            x = moment(x, format)
            if x.isValid()
                x
            else
                throw 'Date not valid'
        else
            if not (x instanceof Date)
                console.log("Value must be a Date type")
                throw "Value must be a Date type"
            moment(x)


datetime = date

today = ->
    moment().toDate()

integer = (x) ->
    if Meteor.isClient
        if x != ''
            reg = /^(\+|-)?\d+$/
            if not reg.test(x)
                throw "Must be an integer"
            else
                parseInt(x)
        else
            null
    else
        if not (typeof x == 'number')
            if x is null
                return null
            throw "Must be an integer"
        
        Math.round(x)

float = (x) ->
    if Meteor.isClient
        if x != ''
            reg = /^(\+|-)?((\d+(\.\d+)?)|(\.\d+))$/
            if not reg.test(x)
                throw "Must be a float"
            else
                parseFloat(x)        
        else
            null
    else
        if not (typeof x == 'number')
            if x is null
                return null
            console.log(x, "Must be a float")            
            throw "Must be a float"
        x
        
# check if is null (and equivalents)        
required = (x) ->
    if x == '' or x is undefined or x is null
        throw "It is required"    
 
min = (limit) ->
    (x) -> 
        if x is null
            return
        if x < limit
            console.log(x, "Value must be greater-equal than " + limit)
            throw "Value must be greater-equal than " + limit
        

max = (limit) ->
    (x) ->
        if x is null
            return
        if x > limit
            console.log(x, "Value must be less-equal than " + limit)
            throw "Value must be less-equal than " + limit
        
smin = (limit) ->
    (x) ->
        if x and x.length < limit
            throw "Length of string must be greater-equal than " + limit
        
        
smax = (limit) ->
    (x) ->
        if x and x.length > limit
            throw "Length of string must be less-equal than " + limit
                

references = (list, attr) ->
    (x) ->  
        if Meteor.isClient
            if x == ''
                return ''
            dct = {}
            dct[attr] = x
            
            obj = list.findOne(dct)

            if obj            
                return obj._id
            else
                throw "Value must be in the list."
        else
            if x == ''
                return ''
            if list.findOne({_id: x})
                return x
            else
                throw "Value must be a valid Id."

references_ = (list, attr, x) ->
    ->
        dct = {}
        dct[attr] = x
        
        obj = list.findOne(dct)

        if obj            
            return obj._id

email = (x) ->
    if x
        reg = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/
        if not reg.test(x)
            throw "The field must be a valid email."

string_select = (list) ->
    (x) ->        
        if x not in list and x != ''
            throw "Value must be in the list"
        x

@model2rform_validators = 
    boolean: boolean
    string: string
    text: text
    nested: nested
    nested_array: nested_array
    string_array: string_array
    date: date
    datetime: datetime
    integer: integer
    float: float
    required: required
    min: min
    max: max
    smin: smin
    smax :smax
    references: references
    references_: references_
    email: email
    string_select: string_select
    

if typeof exports != 'undefined'  
    exports.validators = @model2rform_validators
        