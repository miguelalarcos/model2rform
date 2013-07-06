SandboxedModule = require 'sandboxed-module'
should = require 'should'
assert = require "assert"

moment = require 'moment'
_ = require 'underscore'

Meteor = {}
m = SandboxedModule.require('../validators', 
                            globals: {moment:moment, _:_, Meteor:Meteor}
                            )

integer = m.validators.integer
float = m.validators.float
date = m.validators.date
boolean = m.validators.boolean
string_array = m.validators.string_array

describe 'test boolean validation', ->
    it 'should validate true in the client', ->
        Meteor.isClient = true
        boolean(true).should.equal(true)

    it 'should validate true in the server', ->
        Meteor.isClient = false
        boolean(true).should.equal(true)    

    it 'should not validate "true" in the server', ->
        Meteor.isClient = false
        (->boolean('true')).should.throw()

describe 'test integer validation', ->
    it 'should validate "1" in the client', ->        
        Meteor.isClient = true
        assert.equal(integer('1'), 1)
    
    it 'should validate 1 in the server', ->
        Meteor.isClient = false        
        assert.equal(integer(1), 1)        
        
    it 'should not validate 1z in the client', ->
        Meteor.isClient = true
        (-> integer('1z')).should.throw()

    it "should not validate '11' in the server", ->
        Meteor.isClient = false
        (-> integer('11')).should.throw()
        
describe 'test float validation', ->
    it 'should validate +1 in the client', ->      
        Meteor.isClient = true  
        assert.equal(float('1'), 1)
        
    it 'should validate -.1 in the client', ->    
        Meteor.isClient = true
        float('-.1').should.equal(-0.1)        
        
    it 'should not validate z in the client', ->
        Meteor.isClient = true
        (-> float('z')).should.throw() 

    it 'should validate -.1 in the server', ->    
        Meteor.isClient = false
        float(-.1).should.equal(-0.1)        

    it 'should validate "0.5" in the server' , ->    
        Meteor.isClient = false
        (-> float('0.5')).should.throw()         

        
describe 'test date validation', ->                    
    it "should validate '15-03-1978' in the client", ->
        Meteor.isClient = true
        sd = '15-03-1978'
        d = moment(new Date(1978, 2, 15))        
        date('DD-MM-YYYY')(sd).isSame(d).should.be.true

    it "should throw because not passed date in the server", ->        
        Meteor.isClient = false
        (-> date('DD-MM-YYYY')({})).should.throw()    

    it "should throw because passed an invalid string in the client", ->  
        Meteor.isClient = true      
        (-> date('DD-MM-YYYY')('')).should.throw()    

    it "should validate a Date in the server", ->
        d = new Date(1978, 2, 15)
        Meteor.isClient = false
        date('DD-MM-YYYY')(d).isSame(d).should.be.true  
        
describe 'test string array validation', ->
    it 'should validate "hola\nmundo" in the client', ->
        Meteor.isClient = true
        bool = _.isEqual(string_array("hola\nmundo"), ['hola','mundo'])
        bool.should.be.true

    it  "should validate ['hola', 'mundo'] in the server", ->
        Meteor.isClient = false
        bool = _.isEqual(string_array(['hola','mundo']), ['hola','mundo'])
        bool.should.be.true   

    it "should throw in the server because not an array", ->
        Meteor.isClient = false
        (-> string_array({})).should.throw()     
    
    it "should throw in the server because not string array", ->
        Meteor.isClient = false
        (-> string_array([1,2])).should.throw()     
        

        
        
