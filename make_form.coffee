checked = "x"#\u2612"
unchecked = " "#\u2610"
indeterminate = "--"#\u268B"

_on_change_generic = (form_name, klass) -> (e,t) ->
    name = $(e.target).attr('name')
    value = $(e.target).val()
    _on_change(form_name, klass, name, value)

_on_change_bool = (form_name, klass) -> (e,t) ->
    value = rotate_checkbox(e.target)
    name = $(e.target).attr('name')
    _on_change(form_name, klass, name, value)
    
_on_change = (form_name, klass, name, value) ->
    obj = Session.get(form_name+'_object')
    console.log('name, value', name, value)
    if name not in obj._dirty
        obj._dirty.push(name)
    try
        value = klass[name][0](value)   
        
        for func in klass[name][1..]     
            func(value)
        obj['_error_'+name] = ''
    catch error
        obj['_error_'+name] = error
    
    if moment.isMoment(value)
        value = value.toDate()
    obj[name] = value
    Session.set(form_name+'_object', obj)    
   
rotate_checkbox = (cb) ->
    el = $(cb)
    data = el.text()
    switch data
        when indeterminate
            return false            
        when unchecked
            return true                        
        else
            return null           
                        

#setup the events like typing in the boxes, enter in the search box, ...
make_form_events = (form_name, klass) ->
    dct = {}               
    
    #it shoudl be click, but does not work in chrome (works in opera and firefox)
    dct['mouseup #'+form_name+'_save'] = (e, t)->        
        obj = Session.get(form_name+'_object')         
        klass.save(obj, form_name)   
        
    dct['input .'+form_name+'_attr'] = _on_change_generic(form_name, klass)    
    dct['click .'+form_name+'_attr_bool'] = _on_change_bool(form_name, klass)
    dct['change .'+form_name+'_attr_select'] = _on_change_generic(form_name, klass)
    #these don't work, so I must do where template.rendered with jquery 'on'
    #dct['changeDate .'+form_name+'_attr_date'] = _on_change_generic(form_name, klass)
    #dct['change .'+form_name+'_attr_autocomplete'] = _on_change_generic(form_name, klass)
    #dct['input .'+form_name+'_attr_autocomplete'] = _on_change_generic(form_name, klass)
    dct
    
obj_from_path = (obj, path) ->
    if typeof path == 'string'
        path = path.split('.')
    id = obj._id
    for v in path
        obj = obj[v]
        if obj is undefined 
            break         
    if not obj
        obj = {}
    obj._id = id
    obj._path = path 
    obj
    

form_get = (form_name) ->
    Session.get(form_name+'_object')

form_set = (form_name, obj_path) ->
    Session.set(form_name + '_object_id', obj_path)    
    
#subscribe to the channel of the form_object_id and respective findOne    
_make_autorun = (form_name, klass, parent, path)->->
    if parent isnt null
        x = Session.get(parent+'_object_id')
        if typeof x == 'string'
            id = x
        else
            id = ''

        path_ = path.split('.')
        initial = Session.get(form_name+'_object_id')
        if typeof initial == 'string'
            path_ = initial.split('.')
            initial = {}        
    else
        x = Session.get(form_name+'_object_id')
        if typeof x == 'string'
            id = x
        else
            id = ''
            initial = x
        path_ = []
          
    if id == ''
        obj = null
    else
        Meteor.subscribe(form_name+"_x_id", id)
        obj = klass._collection.findOne({_id: id})

    if path_.length == 0        
        if obj
            Session.set(form_name+'_object', klass.constructor(obj))  
        else
            Session.set(form_name+'_object', klass.constructor({_id:'', _path:[]}, initials=initial))            
    else
        if obj  
            obj = obj_from_path(obj, path_)

            if _.isEqual(obj, {_id: obj._id, _path:path_})
                Session.set(form_name+'_object', klass.constructor(obj, initials=initial))
            else
                Session.set(form_name+'_object', klass.constructor(obj))         
        else            
            #I have doubts about this line
            Session.set(form_name+'_object', klass.constructor({_id:''}, initials=initial))         

_dirty = (form_name) ->
    (attr) ->
        obj = Session.get(form_name+'_object')
        if attr in obj._dirty
            'dirty'
        else
            ''

_invisible = (parent, form_name) ->
    -> 
        if _.isObject(Session.get(parent+'_object_id'))
            return "invisible"
        else
            obj = Session.get(form_name + '_object')
            #spath = obj._path[...-1].join('.')
            #if spath == ""
            #    return ""
            x = Session.get(parent+'_object')
            
            for v in obj._path[...-1]#spath.split('.')            
                x = x[v]
                if x is undefined
                    return "invisible"
            return ""

_disabled = (form_name, klass) ->
    ->
        obj = Session.get(form_name+'_object')
        for attr in klass._attrs
            if obj['_error_'+attr] != ''
                return 'disabled'
                  
        if _.isEqual(obj._dirty, ['_valid'])
            return 'disabled'
        ''
            
# This is what the client must use        
make_form = (template, form_name, klass, parent=null, path=null)->
    
    if not path
        Session.set(form_name+'_object_id', {})
    
    Meteor.autorun _make_autorun(form_name, klass, parent, path)    
   
    template.objeto = -> 
        Session.get(form_name+'_object')
    
    template.dirty = _dirty(form_name)

    if parent
        template.invisible = _invisible(parent, form_name)

    template.format_string_array = (list) ->
        if list
            list.join('\n')  
            
    template.selected = (option, value) ->
        if option == value
            'selected'
        else
            ''
    template.map_null = (value) ->
        if value is null            
            ''        
        else
            value

    template.disabled = _disabled(form_name, klass)            
        
    template.events make_form_events(form_name, klass)
    
    template.from_pk = (data_id, lista, attr) ->        
        lista=window[lista]
        
        obj = lista.findOne({_id: data_id})
        if obj
            obj[attr]           
        
    template.format_datetime = (format, fecha)->
        if fecha            
            fecha = moment(fecha)
            fecha.format(format)
            
    template.format_date = (format, fecha)->
        if fecha 
            fecha = moment(fecha)
            fecha.format(format)
                  
    template.checked = (value) ->        
        if value is null or value is undefined
            return indeterminate
        if value
            checked
        else
            unchecked


    yet_rendered = false

    template.rendered= -> #don't know why, but next events don't work ok if defined in template.events        
        if not yet_rendered
            yet_rendered = true
            
            for_rendered = klass._for_rendered
            for d of for_rendered['date']
                d_ = '#'+form_name+' input[name='+d+']'
                $(d_).datepicker(format: for_rendered['date'][d], autoclose:true)
            selector = '.'+form_name+'_attr_date'
            $(selector).on('changeDate', _on_change_generic(form_name,klass))

            for dt of for_rendered['datetime']
                dt_ = '#'+form_name+' input[name="'+dt+'"]'
                $(dt_).datetimepicker(format: for_rendered['datetime'][dt], autoclose:true)
            selector = '.'+form_name+'_attr_datetime'
            $(selector).on('changeDate', _on_change_generic(form_name,klass))   

            selector = '.'+form_name+'_attr_autocomplete'        
            $(selector).on('change', _on_change_generic(form_name,klass))
            $(selector).on('input', _on_change_generic(form_name,klass))

            for ac of for_rendered['autocomplete']
                [channel, attr, collection] = JSON.parse(for_rendered['autocomplete'][ac])
                Meteor.subscribe(channel)
                target_id = '#'+form_name+' input[name='+ac+']'  
                make_autocomplete target_id, attr, window[collection]
        
make_autocomplete =  (target, attr, collection) ->   
    $(target).typeahead
        source : (q,p)->    
            dct = {}
            dct[attr] = {$regex: ".*"+q+".*"}
            c = collection.find(dct)
            ret = []
            c.forEach (race) ->
                ret.push(race[attr])
            p ret
            ret    

@model2rform_make_form =
    make_form: make_form
    obj_from_path: obj_from_path
    form_get: form_get
    form_set: form_set
        

if typeof exports != 'undefined'    
    exports.make_form =             
        obj_from_path : obj_from_path
        _make_autorun : _make_autorun        
        _dirty : _dirty
        _invisible : _invisible
        _disabled : _disabled
