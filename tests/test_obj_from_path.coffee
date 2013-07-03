should = require 'should'
m = require '../make_form'
_ = require 'underscore'

_obj_from_path = m.make_form._obj_from_path

describe 'test _obj_from_path', ->
    it "should return subobject {_id:'0', x:8}", ->
        obj = {_id:'0', 'n':[{}, {x:8}]}
        subobj = _obj_from_path(obj, ['n', '1'])
        b = _.isEqual(subobj, {_id:'0', x:8})
        b.should.be.ok
        
    it "should return subobject {_id:'0', x:8}", ->
        obj = {_id:'0', 'n':{x:8}}
        subobj = _obj_from_path(obj, ['n'])
        b = _.isEqual(subobj, {_id:'0', x:8})
        b.should.be.ok
           
