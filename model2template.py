import os

class Model: pass

class SubModel(Model): pass

class _Today(object):
    def __repr__(self):
        return 'today'

today = _Today()     

class _True(object):
    def __repr__(self):
        return 'true'

true = _True()

class _False(object):
    def __repr__(self):
        return 'false'

false = _False()

def boolean(): pass    

def text(): pass    

def string(): pass    

def string_select(options):
    def select(): pass
    select.options = options
    select.__name__ = "string_select(['{options}'])".format(options="','".join(options))        
    return select

def date(format, format2):
    def helper(): pass
    helper.__name__ = "date('{f}')".format(f=format)
    helper.format = format    
    helper.format2 = format2
    return helper

def datetime(format, format2):
    def helper():pass
    helper.__name__ = "datetime('{f}')".format(f=format)
    helper.format = format
    helper.format2 = format2
    return helper

def integer(): pass

_float_ = float

def float(): pass

def references(collection, collection_attr, channel):
    def references_(): pass
    references_.collection = collection
    references_.collection_attr = collection_attr
    references_.channel = channel
    references_.__name__ = "references({c},'{ca}')".format(c=collection, ca=collection_attr)    
    return references_

def ref_value(collection, collection_attr, channel):
    def references_(): pass
    references_.collection = collection
    references_.collection_attr = collection_attr
    references_.channel = channel
    references_.__name__ = "ref_value({c},'{ca}')".format(c=collection, ca=collection_attr)    
    return references_



def computed(comp):
    def computed_():pass
    computed_.comp = comp
    return computed_

def string_array(): pass

key_template = {}
key_template['references'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{{{{dirty '{attr}'}}}} {form_name}_attr_autocomplete" value="{{{{from_pk {attr} '{collection}' '{collection_attr}'}}}}" name="{attr}" id="{form_name}_{attr}">
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['ref_value'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{{{{dirty '{attr}'}}}} {form_name}_attr_autocomplete" value="{{{{{attr}}}}}" name="{attr}" id="{form_name}_{attr}">
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""


key_template['generic'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{{{{dirty '{attr}'}}}}  {form_name}_attr" value="{{{{map_null {attr}}}}}" name="{attr}">
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['datetime'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{{{{dirty '{attr}'}}}} {form_name}_attr_datetime" value="{{{{format_datetime '{format_dt}' {attr}}}}}" name="{attr}"  readonly>
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['date'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{{{{dirty '{attr}'}}}} {form_name}_attr_date" value="{{{{format_date '{format_d}' {attr}}}}}" name="{attr}"  readonly>
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['boolean'] = """\
<tr>
    <td>{display}:</td><td><label name="{attr}" class="{{{{dirty '{attr}'}}}} {form_name}_attr_bool label_checkbox">{{{{checked {attr}}}}}</label></td>    
</tr>
"""

key_template['computed_'] = """\
<tr>
    <td>{display}:</td><td>{{{{{comp}}}}}</td>
</tr>
"""

key_template['text'] = """\
<tr>
    <td>{display}:</td><td><textarea {properties} class="{{{{dirty '{attr}'}}}}  {form_name}_attr" name="{attr}">{{{{{attr}}}}}</textarea>    
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['string_array'] = """\
<tr>
    <td>{display}:</td><td><textarea class="{{{{dirty '{attr}'}}}}  {form_name}_attr" name="{attr}">{{{{format_string_array {attr}}}}}</textarea>    
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

#key_template['select'] hardcoded down

init = """\
<template name="{form_name}">
<table id="{form_name}">
{{{{#with objeto}}}}
<tr><td>{{{{_id}}}}</td></tr>
"""

init_submodel = """\
<template name="{form_name}">
<div class="{{{{invisible}}}}">
<table id="{form_name}">
{{{{#with objeto}}}}
<tr><td>{{{{_id}}}}, {{{{_path}}}}</td></tr>
"""

end = """\
{{{{/with}}}}
<tr>
    <td><button id="{form_name}_save" {{{{disabled}}}}>save</button></td>    
</tr>
</table>
</template>
"""

end_submodel = """\
{{{{/with}}}}
<tr>
    <td><button id="{form_name}_save" {{{{disabled}}}}>save</button></td>    
</tr>
</table>
</div>
</template>
"""

def _model2template(model, name, order, out, properties = {}):
    #with open(out, 'w') as f_out:
    f_out = out
    if True:
        form_name = name

        if issubclass(model, SubModel):
            f_out.write(init_submodel.format(form_name=form_name))
        else:
            f_out.write(init.format(form_name=form_name))
        for attr, display in order:
            tipo = getattr(model, attr)#[0]
            if isinstance(tipo, list):
                tipo = tipo[0]
            tipo_name = tipo.__name__
            
            if tipo_name.startswith('references'):
                f_out.write(key_template['references'].format(display=display, form_name=form_name, attr=attr, collection=tipo.collection, collection_attr=tipo.collection_attr))
            if tipo_name.startswith('ref_value'):
                f_out.write(key_template['ref_value'].format(display=display, form_name=form_name, attr=attr, collection=tipo.collection, collection_attr=tipo.collection_attr))        
            if tipo_name in ('string', 'integer', 'float'):
                f_out.write(key_template['generic'].format(display=display, form_name=form_name, attr=attr))
            if tipo_name.startswith('datetime'):
                f_out.write(key_template['datetime'].format(display=display, form_name=form_name, attr=attr, format_dt=tipo.format))
            if tipo_name.startswith('date') and not tipo_name.startswith('datetime'):
                f_out.write(key_template['date'].format(display=display, form_name=form_name, attr=attr, format_d = tipo.format))
            if tipo_name == 'boolean':
                f_out.write(key_template['boolean'].format(display=display, form_name=form_name, attr=attr))
            if tipo_name.startswith('computed'):
                f_out.write(key_template['computed_'].format(display=display, attr=attr, comp=tipo.comp))
            if tipo_name == 'text':
                f_out.write(key_template['text'].format(properties=properties.get(attr, ''), display=display, attr=attr, form_name=form_name))
            if tipo_name == 'string_array':
                f_out.write(key_template['string_array'].format(display=display, attr=attr, form_name=form_name))
            if tipo_name.startswith('string_select'):
                f_out.write("""\
<tr>
    <td>{display}:</td><td><select class="{{{{dirty '{attr}'}}}} {form_name}_attr_select" name="{attr}">
    <option value=""></option>                    
""".format(display=display, form_name=form_name, attr=attr))
                for option in tipo.options:
                    f_out.write("""\
    <option value="{option}" {{{{selected '{option}' {attr}}}}}>{option}</option>                        
""".format(option=option, attr=attr))
                f_out.write("""\
    </select>
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>                        
""".format(attr=attr))    
                
        if issubclass(model, SubModel):
            f_out.write(end_submodel.format(form_name=form_name))
        else:
            f_out.write(end.format(form_name=form_name))        
                

def required():pass
def min(x):
    def helper(): pass
    helper.__name__ = "min({x})".format(x=x)
    return helper
def max(x):
    def helper(): pass
    helper.__name__ = "max({x})".format(x=x)
    return helper    
def smin(x):
    def helper(): pass
    helper.__name__ = "smin({x})".format(x=x)
    return helper    
def smax(x):
    def helper(): pass
    helper.__name__ = "smax({x})".format(x=x)
    return helper    
def email():pass    
def nested(model):
    def helper(): pass
    helper.__name__ = "nested({model})".format(model=model)
    return helper
def nested_array(model):
    def helper(): pass
    helper.__name__ = "nested_array({model})".format(model=model)
    return helper
    
def _model2model(model, out):
    attrs = []
    nested_arrays = []
    for_rendered = {'date':{}, 'datetime': {}, 'autocomplete':{}}
    f_out = out
    if True:        
        if issubclass(model, SubModel):
            f_out.write("class @{model} extends SubModel\n".format(model=model.__name__))
        else:
            f_out.write("class @{model} extends Model\n".format(model=model.__name__))
            
        for attr in (x for x in model.__dict__ if not x.startswith('_')):
            if not isinstance(model.__dict__[attr], list):
                model.__dict__[attr] = [model.__dict__[attr]]
            if model.__dict__[attr][0].__name__ == 'computed_':
                continue
            if not model.__dict__[attr][0].__name__.startswith('nested'):
                attrs.append(attr)
                name_attr = model.__dict__[attr][0].__name__
                if name_attr.startswith('datetime'):
                    for_rendered['datetime'][attr] = model.__dict__[attr][0].format2
                elif name_attr.startswith('date('):
                    for_rendered['date'][attr] = model.__dict__[attr][0].format2
                elif name_attr.startswith('references') or name_attr.startswith('ref_value'):
                    ref = model.__dict__[attr][0]
                    for_rendered['autocomplete'][attr] = '["{a}", "{b}", "{c}"]'.format(a=ref.channel, b=ref.collection_attr, c=ref.collection)
            elif model.__dict__[attr][0].__name__.startswith('nested_array'):
                nested_arrays.append(attr)
  
            text = '    @{attr} : ['.format(attr=attr)
            text += ",".join([elem.__name__ for elem in model.__dict__[attr]])
            text += "]\n"                
            f_out.write(text)        
        
        f_out.write("    @_valid : [boolean]\n")
        f_out.write("    @_collection : "+model.__dict__['_collection'] + '\n')
        f_out.write("    @_attrs : ['_valid'," + ",".join(["'{attr}'".format(attr=attr ) for attr in attrs]) + "]\n")
        f_out.write("    @_nested_arrays : [" + ",".join(["'{attr}'".format(attr=attr) for attr in nested_arrays]) + "]\n")
        f_out.write("    @_for_rendered : {for_rendered}\n".format(for_rendered=for_rendered))
            
def make_all(lista):
    with open('models.coffee', 'w') as out_model, open(os.path.join('client','templates.html'),'w') as out_template:
        out_model.write("""\
validators = model2rform_validators
model = model2rform_model

integer = validators.integer
float = validators.float
boolean = validators.boolean
computed = validators.computed
references = validators.references
ref_value = validators.ref_value

string = validators.string
string_array = validators.string_array
text = validators.text
date = validators.date
datetime = validators.datetime
today = validators.today
required = validators.required
string_select = validators.string_select
email = validators.email
min = validators.min
max = validators.max
smin = validators.smin
smax = validators.smax 

Model = model.Model
SubModel = model.SubModel
nested = validators.nested
nested_array = validators.nested_array
""")
        models = set()
        for m, name, order, properties in lista:
            if m not in models:
                _model2model(m, out_model)     
                models.add(m)
            _model2template(m, name, order, out_template, properties)
   
        
        
