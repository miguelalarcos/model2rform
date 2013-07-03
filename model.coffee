# you must extend from this. All the methods are class methods. This is because
# when you save an object, for example of class A, in the Session, when you
# do the get, you will get a raw javascript object without the methods of A. So I
# have decide to use class methods with de object as argument.
class Model  
    @_path: null # ver si lo utilizo o no
    
    # it will set up the _error_attr attributes
    @constructor: (obj)->
        obj._dirty = []
        for attr in @_attrs        
            try
                val = obj[attr]
                for func in @[attr][1..]
                    func(val)
                obj['_error_'+attr] = ''    
            catch error                   
                obj['_error_'+attr] = error
        obj
    
    @validate : (obj, id) ->
        console.log('validate', obj, id)
        #if arrayEqual([], (x for x of obj))
        if _.isEmpty(obj)
            return false
        
        path_ = null
        for attr of obj
            if path_ is null
                path_ = attr.split('.')[0...-1].join('.')
                continue
            path = attr.split('.')[0...-1].join('.')
            if path != path_
                return false
            path_ = path
         
        ok_for_requireds = false
        for attr of obj
            klass = @
            value = obj[attr]
            path = attr.split('.')[0...-1].join('.')
            for v in attr.split('.')
                if not isNaN(v)
                    continue
                if attr == '_id'
                    if typeof value == 'string'
                        continue
                    else
                        return false
                        
                if v in klass._attrs                    
                    try
                        val = klass[v][0](value)
                        for func in klass[v][1..]
                            func(val)                        
                    catch error
                        return false
                    if not ok_for_requireds
                        ok_for_requireds = true
                        requireds = []
                        for attr in klass._attrs
                            if required in klass[attr]
                                requireds.push(attr)
                        #does not work        
                        #requireds = (x for x in klass.attr if required in klass[attr])
                        if requireds.length > 0
                            dct = {}
                            dct['_id'] = id
                            if path != ''
                                dct[path + '.' + requireds[0]] = null
                            else
                                dct[requireds[0]] = null
                                                        
                            if id is null or klass._collection.find(dct).count() != 0
                                attrs_obj = []
                                for attr of obj
                                    attrs_obj.push(attr.split('.')[-1..][0])
                                for req in requireds
                                    if req not in attrs_obj 
                                        return false
                else      
                    try
                        klass = klass[v][0].klass
                        
                    catch error # when an attr is passed and does not exist in the model
                        return false                    
        return true                      
    
    #update or insert the object in the collection            
    @save : (obj) ->       #se le debe pasar tb el form_name, y este debe desaparecer del modelo       
        if obj._path.length == 0
            dct = {}
            for name in obj._dirty
                dct[name] = obj[name]
            if obj._id
                @_collection.update({_id: obj._id}, {$set:dct})                
            else
                if @._nested_arrays
                    for na in @._nested_arrays
                        dct[na] = []
                _id_ = @_collection.insert(dct)
                Session.set(@_form_name+'_object_id', _id_)
        else
            if obj._path[obj._path.length-1] == '-1'
                path = obj._path[0...-1]
                dct_aux = {}
                for name in obj._dirty
                    dct_aux[name] = obj[name]
                  
                if @._nested_arrays
                    for na in @._nested_arrays
                        dct_aux[na] = []    
                dct = {}
                dct[path.join('.')] = dct_aux
                @_collection.update({_id: obj._id}, {$push: dct })
            else
                path = obj._path.join('.')
                dct_aux = {}
                for name in obj._dirty
                    dct_aux[path+'.'+name] = obj[name]                
                @_collection.update({_id:obj._id}, {$set: dct_aux})

class SubModel extends Model

@model = 
    Model: Model
    SubModel: SubModel

if typeof exports != 'undefined'  
    exports.model = @model