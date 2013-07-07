_on_change_generic = (form_name, klass) -> (e,t) ->
    name = $(e.target).attr('name')
    value = $(e.target).val()
    _on_change(form_name, klass, name, value)

_on_change_bool = (form_name, klass) -> (e,t) ->
    name = $(e.target).attr('name')
    value = $(e.target).is(':checked')    
    _on_change(form_name, klass, name, value)
    
_on_change = (form_name, klass, name, value) ->
    obj = Session.get(form_name+'_object')
    
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
    

#setup the events like typing in the boxes, enter in the search box, ...
make_form_events = (form_name, klass) ->
    dct = {}               
    
    #it shoudl be click, but does not work in chrome (works in opera and firefox)
    dct['mouseup #'+form_name+'_save'] = (e, t)->        
        obj = Session.get(form_name+'_object')         
        klass.save(obj, form_name)   
        
            
    dct['input .'+form_name+'_attr'] = _on_change_generic(form_name, klass)    
    dct['change .'+form_name+'_attr_bool'] = _on_change_bool(form_name, klass)
    dct['change .'+form_name+'_attr_select'] = _on_change_generic(form_name, klass)
    #these don't work, so I must do where template.rendered with jquery 'on'
    #dct['changeDate .'+form_name+'_attr_date'] = _on_change_generic(form_name, klass)
    #dct['change .'+form_name+'_attr_autocomplete'] = _on_change_generic(form_name, klass)
    #dct['input .'+form_name+'_attr_autocomplete'] = _on_change_generic(form_name, klass)
    dct
    
_obj_from_path = (obj, path) ->
    id = obj._id
    for v in path
        obj = obj[v]
    if not obj
        obj = {}
    obj._id = id
    obj
    
#_str_xsplit = (txt) ->
#    json_exp = _.strRight(txt, '.{')
#    if json_exp == txt
#        id_path = txt
#        json_exp = ""
#    else
#        json_exp = "{" + json_exp
#        id_path = _.strLeft(txt, '.{')   
#    return [id_path, json_exp]
    
#subscribe to the channel of the form_object_id and respective findOne    
_make_autorun = (form_name, klass, parent)->->
    if parent isnt null
        x = Session.get(parent+'_object_id')
        if typeof x == 'string'
            id = x
        else
            id = ''
        #[id, jex] = _str_xsplit(Session.get(parent+'_object_id'))
        x = Session.get(form_name+'_object_id')
        if typeof x == 'string'
            path = x.split('.')
        else
            path = x._path
            initial = x._initial
            #[path, initial] = _str_xsplit(Session.get(form_name+'_object_id'))        
    else
        x = Session.get(form_name+'_object_id')
        if typeof x == 'string'
            id = x
        else
            [id, initial] = ['', x]
        path = []
  
        
    Meteor.subscribe(form_name+"_x_id", id)
    
    obj = klass._collection.findOne({_id: id})
    if path.length == 0        
        if obj
            obj._path = []
            Session.set(form_name+'_object', klass.constructor(obj))  
        else
            Session.set(form_name+'_object', klass.constructor({_id:'', _path:[]}, initials=initial))            
    else
        if obj            
            obj = _obj_from_path(obj, path)
            obj._path = path
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

_invisible = (parent) ->
    ->
        if Session.get(parent+'_object_id') == ''
            "invisible"
        else
            ""
_disabled = (form_name, klass) ->
    ->
        obj = Session.get(form_name+'_object')
        for attr in klass._attrs
            if obj['_error_'+attr] != ''
                return 'disabled'
        
        if obj._dirty.length == 0            
            return 'disabled'
        ''
            
# This is what the client must use        
make_form = (template, form_name, klass, for_rendered=null, parent=null, path=null)->
    
    if not path
        Session.set(form_name+'_object_id', '')
    else
        Meteor.autorun ->
            Session.get(parent+'_object_id')
            Session.set(form_name+'_object_id', path)
        
    Meteor.autorun _make_autorun(form_name, klass, parent)    
   
    template.objeto = -> 
        Session.get(form_name+'_object')
    
    template.dirty = _dirty(form_name)

    if parent
        template.invisible = _invisible(parent)

    template.format_string_array = (list) ->
        if list
            list.join('\n')  
            
    template.selected = (option, value) ->
        if option == value
            'selected'
        else
            ''
            
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
                  
    template.is_checked = (value) ->
        if value
            'checked'
        else
            ''
    #Meteor.startup ->
    template.rendered= -> #don't know why, but next events don't work ok if defined in template.events
        #$('.'+form_name+'_attr_date').datepicker(format: 'dd-mm-yyyy', autoclose:true)
        for d of for_rendered['date']
            $(d).datepicker(format: for_rendered['date'][d], autoclose:true)
        $('.'+form_name+'_attr_date').on('changeDate', _on_change_generic(form_name,klass))

        for dt of for_rendered['datetime']
            $(dt).datetimepicker(format: for_rendered['datetime'][dt], autoclose:true)
        #$('.'+form_name+'_attr_datetime').datetimepicker(format: 'dd-mm-yyyy hh:ii:ss', autoclose:true)
        $('.'+form_name+'_attr_datetime').on('changeDate', _on_change_generic(form_name,klass))   
        $('.'+form_name+'_attr_autocomplete').on('change', _on_change_generic(form_name,klass))
        $('.'+form_name+'_attr_autocomplete').on('input', _on_change_generic(form_name,klass))

        for ac of for_rendered['autocomplete']
            #channel = for_rendered['autocomplete'][ac][0]
            #attr = for_rendered['autocomplete'][ac][1]
            #collection = for_rendered['autocomplete'][ac][2]
            [channel, attr, collection] = for_rendered['autocomplete'][ac]
            Meteor.subscribe(channel)
            make_autocomplete ac, attr, collection
        
make_autocomplete =  (target_id, attr, collection) ->     
    $(target_id).typeahead
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

if typeof exports != 'undefined'    
    exports.make_form =             
        _obj_from_path : _obj_from_path
        _make_autorun : _make_autorun        
        _dirty : _dirty
        _invisible : _invisible
        _disabled : _disabled
