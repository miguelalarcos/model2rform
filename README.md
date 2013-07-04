model2rform
===========

Model to reactive form: this is the work of a newbie in Meteor trying to make forms easy. The project uses a little of Python.

Let's go to an example, the *model.py* (you can see the complete [example.](https://github.com/miguelalarcos/demo-model2rform)):

```python
class A(Model):
    _collection = 'myCollection'

    i = [integer, required, min(5), max(10)]
    s = [string, email, smin(7), smax(10)]
    d = [date('DD-MM-YYYY')]
    dt = [datetime('DD-MM-YYYY HH:mm:ss')]
    ss = [string_select(['red','yellow','green']), required]
    f = [float, min(-5.5), max(5.5)]
    b = [boolean]
    t = [text]
    c = [computed('add_i_f')]
    ac = [references('clientsCollection','name')]
    sa = [string_array]
    n = [nested('B')]
    na = [nested_array('C')]
```

We can say several things:

* it maps collection *myCollection* to model *A*. When we'll call *save*, it will use that collection to save the object.
* nested and nested_array: the objects embebed, they are not attributes.
* for each attribute, the restrictions it has to validate with. The first is a transformation (integer transforms de string to an integer), and the rest are validations.
  
  Example:
  
```python  
i = [integer, required, min(5), max(10)]
```

  the algorithm is more or less the next one:

```coffee-script
  val = $(target).val()
  try
    val = integer(val) #transformation
    for func in [required, min(5), max(10)]  #validations
        func(val)
  catch error
    # does not pass the validation
```

If any of *integer* or *func* throws an error, the attr does not pass the validation.
It is important to say that de array must have as first field a transformation (integer, float, date, boolean, string) and then there are zero or more validations (required, imin, ...)

Let's see the other models:

```python
class B(SubModel):
    _collection = 'myCollection'
    x = [integer, required]
    y = [integer]

class C(SubModel):
    _collection = 'myCollection'
    a = [integer]
    b = [integer]

```

The only important thing is that they extend from SubModel. Well, we are in disposition of explain the nested objects of the first model:

```python
n = [nested('B')]
na = [nested_array('C')]
```

*n* is an nested object of model *B*. *na* is an array of objects of model *C*. They are not considered attributes of model *A*. Note that the validations are made inside classes *B* and *C*, and not here in *A*.

Let's see how to translate the Python model to Coffeescript model and the templates. We will use the script *model2template.py*. In a file called model.py we write the code seen of the model and submodel, and then we call:

```python
order_B = (('x', 'X'), ('y', 'Y'))
order_C = (('a', 'A'), ('b', 'B'))
order_A = (('ac', 'Autocomplete'), ('i', 'Integer'), ('f', 'Float'), ('c', 'Computed'), ('b', 'Boolean'), ('s', 'String'), ('d', 'Date'), ('dt', 'Datetime'), ('ss', 'String-select'), ('t', 'Text'), ('sa','StringArray'))

make_all([
    [B, 'B', order_B],
    [C, 'C', order_C],
    [A, 'A', order_A]
    ])
```

We pass the models in the order of dependencies. *A* needs *B* and *C*, so these go first. The second argument of each row is the name of the form. You have to remember it because later you will use it. In the third argument of each row we pass an order and display tuple.

---

The client:

```coffee-script
#file: client/main.coffee
make_form.make_form  Template.A, 'A', A
```

That is the only important thing we have to do in the client (Look at the example because there are more things). To make_form, we have to pass the template of the form, the name of the form (remember this is the name we used when generating the templates) and the model class. If we are making subforms, then the code is:

```coffee-script
make_form.make_form  Template.B, 'B', B, 'A', 'n'
make_form.make_form  Template.C, 'C', C, 'A', 'na.-1'
```

We also pass the parent form and the path. In case of array, indicating -1, which means that the subform will push an object to the array. We will change the path to someting like 'na.3' clicking in a <li>, for example.

---

And the server:

```coffee-script
Meteor.publish("A_x_id", (_id_) ->
    lista.find({_id : _id_})
    )

myCollection.allow
    insert: (userId, doc)->
        return A.validate(doc, null)
        
    update: (userId, doc, fields, modifier)->  
        dct = model2rform_model.dct_from_modifier(modifier)                           
        if not A.validate(dct, doc._id)
            return false
        true
```

Note that we don't call from the objet but from de class: *A.validate(dct, ...*.

---
I think that the reference case is very interesting. Let's explain it:

```coffee-script
ac = [references('clientsCollection','name')]
```

It means that the value displayed references unique attribute *name* of collection clientsCollection, and ac stores de _id. In other words:

```coffee-script
obj = collection.findOne({name: the value displayed})
obj._id
```

And we must subscribe to the source of the autocomplete and call make_autocomplete:

```coffee-script
# clients: an autocompleted field   
Meteor.subscribe('all_clients')
make_autocomplete '#A_ac', 'name', clientsCollection
```
We pass the id of the html input box (formed with the name of the form and the name of the input box) the attr used to match with the input of the user and the collection where to search the results.

Behind the scenes:
------------------

When make_form is called, two important Session vars are created:

* form_name + '\_object_id': the _id of the object mapped with the form
* form_name + '\_object': the object mapped with the form

(Automatically it is made the subscribe to the chanel *form_name+'_x_id'*, that publishes the element with the given *_id*.)

There's one reason to map to an object rather than to Mongo directly. It is because while typing in one box, another field can be computed based in that box.

You set the form\_name\_object\_id, and then form\_name\_object is calculated with a findOne:

```coffee-script
_make_autorun = (form_name, klass, parent)->->
    if parent isnt null
        id = Session.get(parent+'_object_id')
        path = Session.get(form_name+'_object_id').split('.')
    else
        id = Session.get(form_name+'_object_id')
        path = []
  
        
    Meteor.subscribe(form_name+"_x_id", id)
    
    obj = klass._collection.findOne({_id: id})
    if path.length == 0        
        if obj
            obj._path = []
            Session.set(form_name+'_object', klass.constructor(obj))  
        else
            Session.set(form_name+'_object', klass.constructor({_id:'', _path:[]}))
    else
        if obj            
            obj = _obj_from_path(obj, path)
            obj._path = path
            Session.set(form_name+'_object', klass.constructor(obj))
        else            
            #I have doubts about this line
            Session.set(form_name+'_object', klass.constructor({_id:''}))         
```

If we set the form\_name\_object\_id with a '', if it is an instance of a SubModel, the form is hidden. If it is an instance of Model, then when you'll save, an insert will be done.

* Dependencies: 
    * [bootstrap date-picker](https://github.com/eternicode/bootstrap-datepicker). I have select the es locale and put next to bootstrap-datepicker.js and with a name so the locale loads after bootstrap-datepicker.js.
    
    * http://www.malot.fr/bootstrap-datetimepicker/

* TODO: more comments to the code. More tests.
