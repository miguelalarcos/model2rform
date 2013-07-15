checked = "x"#\u2612"
unchecked = " "#\u2610"
indeterminate = "--"#\u268B"

class Search 
    @constructor : (obj)->
        for attr in @_attrs
            obj['_error_'+attr] = ''
        return obj

eq = (value) ->
    if value == ''
        return null
    return value

gt = (value)->
    if value == ''
        return null
    return {"$gt": value}

gte = (value)->
    if value == ''
        return null
    return {"$gte": value}


lt = (value)->
    if value == ''
        return null
    return {"$lt": value}


lte = (value)->
    if value == ''
        return null
    return {"$lte": value}

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

on_change = (search_name, klass, name, value)->
    console.log(name, value)
    obj = Session.get(search_name + '_object')
    try    
        klass[name][0](value)  
        obj['_error_'+name] = ''
    catch error
        obj['_error_'+name] = error

    obj[name] = value
    Session.set(search_name + '_object', obj)        
    

on_change_bool = (search_name, klass) ->
    (e, t) ->
        value = rotate_checkbox(e.target)
        name = $(e.target).attr('name')
        on_change(search_name, klass, name, value)

on_change_generic = (search_name, klass) ->
    (e, t) ->
        name = $(e.target).attr('name')
        value = $(e.target).val()
        on_change(search_name, klass, name, value)


make_search = (template, search_name, klass) ->
    Session.set(search_name + '_object', klass.constructor({}))

    template.objeto = ->
        Session.get(search_name+'_object')

    dct = {}
    dct['mouseup #'+search_name+'_search'] = (e,t)->
        selector = {}
        obj = Session.get(search_name+'_object')
        for attr in klass._attrs
            value = obj[attr]
            if value != '' and value isnt null and value isnt undefined
                value = klass[attr][0](value)
                if moment.isMoment(value)
                    value = value.toDate()
                value = klass[attr][1](value) 
            
                selector[attr] = value

        console.log(selector)
    dct['input .'+search_name+'_attr'] = on_change_generic(search_name, klass)
    dct['click .'+search_name+'_attr_bool'] = on_change_bool(search_name, klass)
    dct['change .'+search_name+'_attr_select'] = on_change_generic(search_name, klass)
    template.events = dct

    template.format_date = (format, fecha)->
        if fecha 
            fecha = moment(fecha)
            fecha.format(format)
    
    template.disabled = ->
        obj = Session.get(search_name+'_object')
        for attr in klass._attrs
            if obj['_error_'+attr] != ''
                return 'disabled'
                          
        ''

    template.checked = (value) ->      
        console.log('template.checked', value)  
        if value is null or value is undefined
            return indeterminate
        if value
            checked
        else
            unchecked

    yet_rendered = false
    template.rendered= ->
        if not yet_rendered
            yet_rendered = true

            for_rendered = klass._for_rendered
            for d of for_rendered['date']
                d_ = '#'+search_name+' input[name='+d+']'
                $(d_).datepicker(format: for_rendered['date'][d], autoclose:true)
            selector = '.'+search_name+'_attr_date'
            $(selector).on('changeDate', on_change_generic(search_name,klass))

            for dt of for_rendered['datetime']
                dt_ = '#'+search_name+' input[name="'+dt+'"]'
                $(dt_).datetimepicker(format: for_rendered['datetime'][dt], autoclose:true)
            selector = '.'+search_name+'_attr_datetime'
            $(selector).on('changeDate', on_change_generic(search_name,klass))   


@model2rform_search =
    gt: gt
    gte: gte
    eq: eq
    lte: lte
    lt: lt
    make_search: make_search
    Search: Search