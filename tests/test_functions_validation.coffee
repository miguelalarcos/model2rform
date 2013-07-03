SandboxedModule = require 'sandboxed-module'
should = require 'should'
assert = require "assert"

moment = require 'moment'
_ = require 'underscore'

m = SandboxedModule.require('../validators', 
                            globals: {moment:moment, _:_}
                            )

integer = m.validators.integer
float = m.validators.float
date = m.validators.date
string_array = m.validators.string_array

describe 'test integer validation', ->
    it 'should validate "1"', ->        
        assert.equal(integer('1'), 1)
    
    it 'should validate 1', ->        
        assert.equal(integer(1), 1)        
        
    it 'should not validate 1z', ->
        (-> integer('1z')).should.throw()
        
describe 'test float validation', ->
    it 'should validate +1', ->        
        assert.equal(float('1'), 1)
        
    it 'should validate -.1', ->    
        float('-.1').should.equal(-0.1)
        #assert.equal(float('-.1'), -0.1)
        
    it 'should not validate z', ->
        (-> float('z')).should.throw() 

        
describe 'test date validation', ->
    it 'should validate date', ->
        d = new Date(1978, 2, 15)
        a = date('DD-MM-YYYY')(d)
        b = moment(d)
        bool = a.isSame(b)
        bool.should.be.true                
        
    it "should validate '15-03-1978'", ->
        sd = '15-03-1978'
        d = moment(new Date(1978, 2, 15))        
        date('DD-MM-YYYY')(sd).isSame(d).should.be.true

    it "should throw because passed not a string nor date", ->        
        (-> date('DD-MM-YYYY')({})).should.throw()    

    it "should throw because passed an invalid string", ->        
        (-> date('DD-MM-YYYY')('')).should.throw()    
        
describe 'test string array validation', ->
    it 'should validate "hola\nmundo"', ->
        #string_array("hola\nmundo").should.eql(['hola','mundo'])
        bool = _.isEqual(string_array("hola\nmundo"), ['hola','mundo'])
        bool.should.be.true

    it  "should validate ['hola', 'mundo']", ->
        bool = _.isEqual(string_array(['hola','mundo']), ['hola','mundo'])
        bool.should.be.true   

    it "should throw", ->
        (-> string_array({})).should.throw()     
    
        

        
        
