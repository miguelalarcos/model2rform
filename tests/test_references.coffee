should = require 'should'
assert = require("assert")

Meteor = {}
Meteor.isClient = true

SandboxedModule = require('sandboxed-module')
m = SandboxedModule.require('../validators', 
                            globals: {Meteor: Meteor}
                            )
sinon = require './sinon'                            
references = m.validators.references

describe 'test references validation', -> 
    collection = sinon.spy()
    f = collection.findOne = sinon.stub()
    it 'should validate references', ->        
        f.returns({_id:'1'})
        
        references(collection, 'name')('red').should.eql('1')
        f.calledWith({name:'red'}).should.be.true
    it 'should throw an exception', ->
        f.returns(null)
        (-> references(collection, 'name')('re')).should.throw()
        
    it 'should validate when isServer', ->
        Meteor.isClient = false
        f.returns({_id:1, name:'red'})
        references(collection, 'name')('1').should.eql('1')
        f.calledWith({_id: '1'}).should.be.true    
         
    it 'shuld throw an exception when isServer', ->
        f.returns(null)
        (-> references(collection, 'name')('2')).should.throw()    
        
        
   
        
                                        
                                            
        

