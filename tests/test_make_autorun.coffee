SandboxedModule = require('sandboxed-module')

should = require 'should'
sinon = require './sinon'   
_ = require 'underscore'

m = require './model_A'
A = m.A
B = m.B

m = require './fake_utils'
Session = m.Session
Meteor=m.Meteor
session = new Session()   
dct = {Session: session,Meteor: Meteor,_:_}

m = SandboxedModule.require('../make_form', 
                            globals: dct
                            )
make_autorun = m.make_form._make_autorun


describe 'test make autorun', ->
    before ->
        A._collection = sinon.spy()
        A._collection.findOne = sinon.stub()
        B._collection = sinon.spy()
        B._collection.findOne = sinon.stub()
    beforeEach -> session.clear()                
    
    it 'without path should findOne with _id = 0', ->
        A._collection.findOne.returns({_id: '0', a:8})
        session.set('form1_object_id', '0')
        make_autorun('form1', A, null)()
        obj = session.get('form1_object')    
        b = _.isEqual(obj, {_id:'0', _path:[], _dirty: ['_valid'], _valid:true, a:8, _error_a:'', _error_b : '', _error__valid : ''})
        
        b.should.be.ok
        
    it 'without path should not findOne with initial', ->
        A._collection.findOne.returns(null)
        session.set('form1_object_id', {b: 1})
        make_autorun('form1', A, null)()
        obj = session.get('form1_object')     
        b = _.isEqual(obj, {_id:'', _path:[], _dirty: ['_valid', 'b'], _valid:true, _error_a:'It is required', _error_b : '', b:1, _error__valid: ''})
        
        b.should.be.ok    
        
    it 'with path should findOne with _id=0.n.0', ->
        B._collection.findOne.returns({_id: '0', a:8, n:[{x:0}]})
        session.set('form1_object_id', 'n.0')
        session.set('parent_object_id', '0')
        make_autorun('form1', B, 'parent', 'n.0')()
        obj = session.get('form1_object')  
        b = _.isEqual(obj, {_id:'0', _path:['n','0'], _dirty: ['_valid'], _valid:true, x:0, _error_x:'', _error_y : '', _error__valid : ''})

        b.should.be.ok
        B._collection.findOne.calledWith({_id: '0'})
        
    it 'with path should findOne with _id=0.n.-1 and initial', ->
        B._collection.findOne.returns({_id: '0', a:8, n:[{x:0}]})
        session.set('form1_object_id', {x:8})
        session.set('parent_object_id', '0')
        make_autorun('form1', B, 'parent', 'n.-1')()
        obj = session.get('form1_object')  
        b = _.isEqual(obj, {_id:'0', _path:['n','-1'], _dirty: ['_valid', 'x'], _valid: true, x:8, _error_x:'', _error_y : '', _error__valid : ''})

        b.should.be.ok

    it 'with path should findOne with _id=0.n', ->
        B._collection.findOne.returns({_id: '0', a:8, n:{x:0}})
        session.set('form1_object_id', {})
        session.set('parent_object_id', '0')
        make_autorun('form1', B, 'parent','n')()
        obj = session.get('form1_object')  
        b = _.isEqual(obj, {_id:'0', _path:['n'], _dirty: ['_valid'], _valid:true, x:0, _error_x:'', _error_y : '', _error__valid : ''})

        b.should.be.ok     
    
    it 'with path should findOne with _id=0.n and initial', ->
        B._collection.findOne.returns({_id: '0', a:8 })
        session.set('form1_object_id', {x:8})
        session.set('parent_object_id', '0')
        make_autorun('form1', B, 'parent','n')()
        obj = session.get('form1_object')          
        b = _.isEqual(obj, {_id:'0', _path:['n'], _dirty: ['_valid', 'x'], _valid:true, x:8, _error_x:'', _error_y : '', _error__valid : ''})

        b.should.be.ok  

    it 'with path should findOne with _id=0.n.0.n2.1', ->
        B._collection.findOne.returns({_id: '0', a:8, n:[{n2:[{x:0},{x:1}]}]})
        session.set('form1_object_id', 'n.0.n2.1')
        session.set('parent_object_id', '0')
        make_autorun('form1', B, 'parent', 'n.0.n2.1')()
        obj = session.get('form1_object')  
        b = _.isEqual(obj, {_id:'0', _path:['n','0', 'n2', '1'], _dirty: ['_valid'], _valid:true, x:1, _error_x:'', _error_y : '', _error__valid : ''})

        b.should.be.ok
        