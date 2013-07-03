sinon = require './sinon' 

class Session
    constructor : -> @_container = {}
    get : (name) -> @_container[name]
    set : (name, value) -> @_container[name] = value
    clear : -> @_container = {}
    
Meteor = sinon.spy()
Meteor.subscribe = sinon.spy()
Meteor.autorun = sinon.spy()

exports.Meteor = Meteor
exports.Session = Session
