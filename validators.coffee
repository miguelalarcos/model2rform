# #### VALIDATORS AND TRANSFORMATIONS #########
boolean = (x) -> x
    
string = (x) -> x    

text = (x) -> x

nested = (klass) ->
    klass: klass

nested_array = (klass) ->
    klass: klass     

string_array = (txt) ->
    if typeof txt == 'string' 
        return txt.split('\n')

    if _.isArray(txt)
        for v in txt
            if not typeof v == 'string'
                throw "The array must be of strings."
        return txt
    
    throw 'string_array error'

date = (format) ->
    (x)->         
        if x instanceof Date             
            moment(x)
        else
            if not _.isString(x)
                throw 'Date not valid'
            x = moment(x, format)
            if x.isValid()
                x
            else
                throw 'Date not valid'

datetime = date

integer = (x) ->
    if x != ''
        reg = /^(\+|-)?\d+$/
        if not reg.test(x)
            throw "Must be an integer"
        else
            parseInt(x)
    else
        ''

float = (x) ->
    if x != ''
        reg = /^(\+|-)?((\d+(\.\d+)?)|(\.\d+))$/
        if not reg.test(x)
            throw "Must be a float"
        else
            parseFloat(x)        
    else
        ''
        
# check if is null (and equivalents)        
required = (x) ->
    if x == '' or x is undefined or x is null
        throw "It is required"    
 
min = (limit) ->
    (x) -> #check if x >= limit, then ok
        if x < limit
            throw "Value must be greater-equal than " + limit
        

max = (limit) ->
    (x) ->
        if x > limit
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

email = (x) ->
    if x
        reg = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/
        if not reg.test(x)
            throw "The field must be a valid email."

string_select = (list) ->
    (x) ->        
        if x not in list
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
    email: email
    string_select: string_select
    

if typeof exports != 'undefined'  
    exports.validators = @model2rform_validators
        