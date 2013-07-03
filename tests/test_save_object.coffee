should = require 'should'
sinon = require './sinon'   
_ = require 'underscore'

m = require './model_A'
A = m.A
B = m.B
session = m.session
#klass_from_path = m._klass_from_path
#B.collection.insert = sinon.stub()

describe 'test save object', ->
    before ->
        A._collection = sinon.spy()
        A._collection.update = sinon.stub()
        A._collection.insert = sinon.stub()
        A._collection.insert.returns('0')
        
        B._collection = sinon.spy()
        B._collection.update = sinon.stub()
    beforeEach -> session.clear()                
    
    it 'should save {_path:[], dirty:["a"], a: 8, b: 9} with insert', ->
        obj = {_path:[], _dirty:["a"], a: 8, b: 9}
        A.save(obj)
        A._collection.insert.calledWith({a: 8, n: []}).should.be.ok
        b = _.isEqual(session._container, {form_object_id: '0'})
        b.should.be.ok
        
    it 'should save {_path:[], _id:"0", dirty["a"], a:8, b:9} with update', ->
        obj = {_path:[], _id:'0', _dirty:["a"], a:8, b:9}
        A.save(obj)
        A._collection.update.calledWith({_id: '0'}, {$set:{a:8}}).should.be.ok
        
    it "should save {_path:['n','-1'], _id:'0', dirty:['x'], x:3, y:9} with push", ->
        obj = {_path:['n','-1'], _id:'0', _dirty:['x'], x:3, y:9}
        B.save(obj)
        B._collection.update.calledWith({_id:'0'}, {$push: {'n':{x:3, nn:[]}}}).should.be.ok
        
    it "should save {_path:['n','1'], _id:'0', dirty:['x'], x:3, y:9} with update $set", ->
        obj = {_path:['n','2'], _id:'0', _dirty:['x'], x:3, y:9}
        B.save(obj)
        B._collection.update.calledWith({_id:'0'}, {$set:{'n.2.x': 3}}).should.be.ok
    
    it "should save {_path:['n','1'], _id:'0', dirty:['x'], x:3, y:9} with update $set", ->
        obj = {_path:['n'], _id:'0', _dirty:['x'], x:3, y:9}
        B.save(obj)
        B._collection.update.calledWith({_id:'0'}, {$set:{'n.x': 3}}).should.be.ok


        