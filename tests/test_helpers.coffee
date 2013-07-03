SandboxedModule = require('sandboxed-module')
sinon = require './sinon' 
should = require 'should'

_ = require 'underscore'
m = require './model_A'
A = m.A
session = m.session
m = require './fake_utils'
Meteor=m.Meteor

dct = {Session: session,Meteor: Meteor}

m = SandboxedModule.require('../make_form', 
                            globals: dct
                            )


_dirty = m.make_form._dirty
_invisible = m.make_form._invisible
_disabled = m.make_form._disabled


describe 'test template helpers', ->    

    beforeEach -> session.clear()        
    
    it "dirty helper should return 'dirty'", ->        
        dirty = _dirty('form')
        session.set('form_object', {_id:0, x:8, y:0, _dirty:['x']})
        
        dirty('x').should.eql('dirty')
    
    it "dirty helper should return ''", ->        
        dirty = _dirty('form')
        
        session.set('form_object', {_id:0, x:8, y:0, _dirty:[]})        
        dirty('x').should.eql('')    
        
    it "invisible helper should return 'invisible'", ->
        invisible = _invisible('form')
        session.set('form_object_id', '')
        
        invisible().should.eql('invisible')
        
    it "invisible helper should return ''", ->
        invisible = _invisible('form')
        session.set('form_object_id', '0')
        
        invisible().should.eql('')    

    it "disabled helper should return 'disabled' when (len of dirty == 0)", ->
        disabled = _disabled('form', A)   
        obj = A.constructor({_id:0, a:8, b:0}) 
        session.set('form_object', obj)  

        disabled().should.eql('disabled')

    it "disabled helper should return 'disabled' when there's errors", ->
        disabled = _disabled('form', A)   
        obj = A.constructor({_id:0, a:8, b:0})
        obj._dirty = ['a']
        obj._error_a = 'error' 
        session.set('form_object', obj)  

        disabled().should.eql('disabled')

    it "disabled helper should return '' when there's dirty and no errors", ->
        disabled = _disabled('form', A)    
        obj = A.constructor({_id:0, a:8, b:0})
        obj._dirty = ['a']
        session.set('form_object', obj)  

        disabled().should.eql('')

