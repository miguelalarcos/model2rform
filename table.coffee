form_set = model2rform_make_form.form_set
form_get = model2rform_make_form.form_get

make_table_from_array = (template, form_name_parent, form_name_sub, path) ->
    template.row = ->        
        obj = form_get(form_name_parent)
        ret = []
        if obj[path]       
            for linea, i in obj[path]
                if linea._valid
                    linea = _.clone(linea)
                    linea._path = path + '.' + i
                    ret.push(linea)          
        return ret

    template.events =
        'click a.listado' : (e,t) ->
            path_ = $(e.target).attr('path')
            form_set(form_name_sub, path_)


make_table_from_collection = (template, collection, search_name, form_name) ->
    template.row = ->
        selector = Session.get(search_name + '_selector')
        return collection.find(selector)

    template.events =
        'click a.listado': (e,t) ->
            _id = $(e.target).attr('_id')
            form_set(form_name, _id)


@model2rform_table =
    make_table_from_array: make_table_from_array
    make_table_from_collection: make_table_from_collection

