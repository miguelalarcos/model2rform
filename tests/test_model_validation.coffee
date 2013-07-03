should = require 'should'
assert = require("assert")
sinon = require './sinon'   
#_ = require 'underscore'

m = require './model_A'
A = m.A
B = m.B

make_find_count = (ret) ->
    find = sinon.stub()
    _ = sinon.stub()
    find.returns(_)
    _.count = sinon.stub()
    _.count.returns(ret)
    find

describe 'test model validation', ->
    
    beforeEach ->
        A._collection.find = make_find_count 1
        B._collection.find = make_find_count 1
    before ->
        A._collection = sinon.stub()                
        
        B._collection = sinon.spy()
    
    it 'should not validate {}', ->
        A.validate({}).should.be.not.ok
        
    it "should not validate {a: 1, 'n.x': 5} because mixes paths", ->
        A.validate({a: 1, 'n.x': 5}).should.be.not.ok  
        
    it 'should validate {a:1, b:2}', ->
        A.validate({a:1, b:2}, null).should.be.ok        
        
    it 'should validate {a:1}', ->
        A.validate({a:1}, null).should.be.ok
        
    it 'should not validate {b:1} because a is required', ->
        A.validate({b:1}, null).should.be.not.ok    
        
    it 'should not validate {a:1, z:1} because z is not in model', ->
        A.validate({a:1, z:1}, null).should.be.not.ok    
        
    it 'an update that should validate {a:1, b:1}', ->
        A.validate({a:1, b:1}, '0').should.be.ok
        
    it 'should validate called with', ->
        A.validate({a:1, b:1}, '0')
        A._collection.find.calledWith({_id: '0', a: null}).should.be.ok
        
    it 'should validate nested object {"n.x":5}', ->
        A.validate({'n.x':5}, '0').should.be.ok
        
    it "should validate find calledWith {_id:'0', 'n.x': null}", ->
        A.validate({'n.x':5}, '0')
        B._collection.find.calledWith({_id:'0', 'n.x': null}).should.be.ok
        
    it 'should not validate nested object {"n.y":5} because n.x is required', ->
        A.validate({'n.y':5}, '0').should.be.not.ok    
        
    it 'should validate nested object {"n.z":5} because z is not part of the model', ->
        A.validate({'n.z':5}, '0').should.be.not.ok
        
    it 'should validate nested array object {"n.1.x":5}', ->
        A.validate({'n.1.x':5}, '0').should.be.ok 
        
    it 'should not validate nested array object {"n.y":5} becaus x is required', ->
        A.validate({'n.y':5}, '0').should.be.not.ok
        
    it 'should validate nested array object {"n.1.z":5} because z is not part of the model', ->
        A.validate({'n.1.z':5}, '0').should.be.not.ok
        
describe 'test model validation', ->
    before ->
        B._collection = sinon.spy()
        B._collection.find = make_find_count 0
    
    it 'should validate nested array object {"n.1.y":5} although x is required, because is an update', ->
        A.validate({'n.1.y':5}, '0').should.be.ok 
        

