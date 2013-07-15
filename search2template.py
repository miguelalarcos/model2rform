import os

def eq(): pass
def gt(): pass
def gte(): pass
def lt(): pass
def lte(): pass

def integer():pass
def float():pass
def string():pass
def boolean():pass
def date(format_1, format_2):
    def helper(): pass
    helper.__name__ = "date('{f}')".format(f=format_1)
    helper.format_1 = format_1
    helper.format_2 = format_2
    return helper

def datetime(format_1, format_2):    
    def helper(): pass
    helper.__name__ = "datetime('{f}')".format(f=format_1)
    helper.format_1 = format_1
    helper.format_2 = format_2
    return helper

def string_select(options):
    def select(): pass
    select.options = options
    select.__name__ = "string_select(['{options}'])".format(options="','".join(options))        
    return select

init = """\
<template name="{search_name}">
<table id="{search_name}">
{{{{#with objeto}}}}
"""

end = """\
{{{{/with}}}}
<tr>
    <td><button id="{search_name}_search" {{{{disabled}}}}>search</button></td>    
</tr>
</table>
</template>
"""

key_template = {}

key_template['generic'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{search_name}_attr" name="{attr}">
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['boolean'] = """\
<tr>
    <td>{display}:</td><td><label name="{attr}" class="{search_name}_attr_bool label_checkbox">{{{{checked {attr}}}}}</label></td>
</tr>
"""

key_template['date'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{search_name}_attr_date" name="{attr}" readonly>
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

key_template['datetime'] = """\
<tr>
    <td>{display}:</td><td><input type="text" class="{search_name}_attr_datetime" name="{attr}" readonly>
    <div class="error">{{{{_error_{attr}}}}}</div></td>
</tr>
"""

def make_all(lista):
    with open(os.path.join('client', 'searches.coffee'), 'w') as out_search, open(os.path.join('client','template_search.html'), 'w') as out_template:
        out_search.write("""\
validators = model2rform_validators
boolean = validators.boolean
string = validators.string
date = validators.date
datetime=validators.datetime
integer = validators.integer
float = validators.float
string_select = validators.string_select

search = model2rform_search
eq=search.eq
gt=search.gt
gte=search.gte
lt=search.lt
lte=search.lte
Search=search.Search

""")
        for klass, name, order in lista:
            dct = klass.__dict__
            out_template.write(init.format(search_name=name))
            for attr, display in order:                
                if dct[attr][0] in (integer, float, string):
                    out_template.write(key_template['generic'].format(display=display, search_name=name, attr=attr))
                if dct[attr][0] == boolean:
                    out_template.write(key_template['boolean'].format(display=display, search_name=name, attr=attr))
                if dct[attr][0].__name__.startswith('date('):
                    out_template.write(key_template['date'].format(display=display, search_name=name, attr=attr))
                if dct[attr][0].__name__.startswith('datetime('):
                    out_template.write(key_template['datetime'].format(display=display, search_name=name, attr=attr))
                if dct[attr][0].__name__.startswith('string_select'):
                    out_template.write("""\
<tr>
    <td>{display}:</td><td><select class="{search_name}_attr_select" name="{attr}">
    <option value=""></option>                    
""".format(display=display, search_name=name, attr=attr))
                
                    for option in dct[attr][0].options:
                        out_template.write("""\
    <option value="{option}" {{{{selected '{option}' {attr}}}}}>{option}</option>                        
""".format(option=option, attr=attr))                    

            out_template.write(end.format(search_name=name))
            
            #search model
            out_search.write("class @{search} extends Search\n".format(search=name))
            attrs = []
            for_rendered = {'date': {}, 'datetime':{}}
            for attr in (x for x in klass.__dict__ if not x.startswith('_')):
                attrs.append(attr)
                out_search.write('    @{attr} : ['.format(attr=attr))
                out_search.write(",".join(elem.__name__ for elem in dct[attr]))
                out_search.write("]\n")
                if dct[attr][0].__name__.startswith('datetime('):
                    for_rendered['datetime'][attr] = dct[attr][0].format_2
                if dct[attr][0].__name__.startswith('date('):
                    for_rendered['date'][attr] = dct[attr][0].format_2
            out_search.write("    @_attrs : [" + ",".join(["'{attr}'".format(attr=attr ) for attr in attrs]) + "]\n")
            out_search.write("    @_for_rendered: {for_rendered}\n".format(for_rendered=for_rendered))

