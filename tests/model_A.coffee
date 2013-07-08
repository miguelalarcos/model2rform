SandboxedModule = require('sandboxed-module')
moment = require 'moment'
_ = require 'underscore'

m = require "./fake_utils"
session = new m.Session()   
dct = {Session: session,Meteor: m.Meteor, moment:moment, _:_}

validators = SandboxedModule.require('../validators', 
                            globals: dct
                            )

dct['model2rform_validators'] = validators.validators
model = SandboxedModule.require('../model', 
                            globals: dct
                            )

Model = model.model.Model
SubModel = model.model.SubModel
integer = validators.validators.integer
required = validators.validators.required
nested = validators.validators.nested
boolean = validators.validators.boolean

class B extends SubModel
    @_valid : [boolean]
    @x : [integer, required]
    @y : [integer]
    @_attrs :['x', 'y', '_valid']  
    @nn : [nested(B)]
    @_nested_arrays : ['nn'] 
    
class A extends Model
    @_valid : [boolean]
    @a : [integer, required]
    @b : [integer]
    @n : [nested(B)]
    @_form_name : 'form'
    @_attrs : ['a','b','_valid']
    @_nested_arrays : ['n']
    
exports.A = A    
exports.B = B
exports.session = session

