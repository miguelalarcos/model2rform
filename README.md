model2rform
===========

Model to reactive form: this is the work of a newbie in Meteor trying to make forms easy. The project uses a little of Python.

Let's go to an example, the *model.py* (you can see the complete [example.](https://github.com/miguelalarcos/demo-model2rform)):

```python
class A(Model):
    _collection = 'myCollection'

    i = [integer, required, min(5), max(10)]
    s = [string, email, smin(7), smax(10)]
    #we must specify the format in momentjs and in datepicker
    d = [date('DD-MM-YYYY', 'dd-mm-yyyy')]
    dt = [datetime('DD-MM-YYYY HH:mm:ss', 'dd-mm-yyyy hh:ii:ss')]
    ss = [string_select(['red','yellow','green']), required]
    f = [float, min(-5.5), max(5.5)]
    b = [boolean]
    t = [text]
    c = [computed('add_i_f')]
    ac = [references('clientsCollection','name','all_clients')]
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
It is important to say that de array must have as first field a transformation (integer, float, date, boolean, string) and then there are zero or more validations (required, min, ...)

---

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

Let's see how to translate the Python model to Coffeescript model and the templates. We will use the script *model2template.py*. In a file called *model.py* we write the code seen of the model and submodel, and then we call:

```python
order_B = (('x', 'X'), ('y', 'Y'))
order_C = (('a', 'A'), ('b', 'B'))
order_A = (('ac', 'Autocomplete'), ('i', 'Integer'), ('f', 'Float'), ('c', 'Computed'), ('b', 'Boolean'), ('s', 'String'), ('d', 'Date'), ('dt', 'Datetime'), ('ss', 'String-select'), ('t', 'Text'), ('sa','StringArray'))

make_all([
    [B, 'B', order_B, {}],
    [C, 'C', order_C, {}],
    [A, 'A', order_A, {'t': 'rows="10"'}]
    ])
```

We pass the models in the order of dependencies. *A* needs *B* and *C*, so these go first. The second argument of each row is the name of the form. You have to remember it because later you will use it. In the third argument of each row we pass an order and display tuple. The next one are properties to he html element.

---

The client:

```coffee-script
model2rform_make_form.make_form  Template.A, 'A', A
```

That is the only important thing we have to do in the client (Look at the example because there are more things). To make_form, we have to pass the template of the form, the name of the form (remember this is the name we used when generating the templates) and the model class. 

If we are making subforms, then the code is:

```coffee-script
make_form.make_form  Template.B, 'B', B, 'A', 'n'
make_form.make_form  Template.C, 'C', C, 'A', 'na.-1'
```

We also pass the parent form and the path. In case of array, indicating -1, which means that the subform will push an object to the array. When we change the path to something like na.0, then save will save to the position 0 of the array.

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
I think that the reference case is very interesting. Let's explain it a bit:

```python
ac = [references('clientsCollection','name','all_clients')]
```

It means that the value displayed references unique attribute *name* of collection clientsCollection, and ac stores de _id. In other words:

```coffee-script
obj = collection.findOne({name: *the value displayed*})
obj._id
```
We have to pass also the channel to subscribe to get the objects to display.

Behind the scenes:
------------------

When make_form is called, two important Session vars are created:

* form_name + '\_object_id': 
    * form: the _id of the object mapped with the form or an object of initial values.
    * subform: path to the subobject or an object of initial values.
* form_name + '\_object': the object mapped with the form

(Automatically it is made the subscribe to the chanel *form_name\_x\_id*, that publishes the element with the given *\_id*.)

There's one reason to map to an object rather than to Mongo directly. It is because while typing in one box, another field can be computed based in that box.

You set the *form\_name\_object\_id*, and then *form\_name\_object* is calculated with a findOne. This is the code:

```coffee-script
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
            path_[path_.length-1] = initial
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
            obj._path = []
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
            Session.set(form_name+'_object', klass.constructor({_id:''}, initials=initial))         
```

In case of form, you can set the form_name_object_id with an _id or with an object of initial values. In the first case, a findOne will be done and the object retrieved is populated. The subforms are visible and ready to modify the data. In the second case, an object with initial values is populated, pending to be inserted. The subforms are hidden till the form is inserted.

In case of subform:

* nested: you can pass an object of initial values.
* nested array: you can pass an index position of the array meaning the object to display; you can pass an object of initial values if previously you have passed '-1'.

The delete of objects is implemented setting the attr *\_valid* to false. You have to use the class method *setInvalid*.

* Dependencies: 
    * [bootstrap date-picker](https://github.com/eternicode/bootstrap-datepicker). I have select the es locale.
    
    * [datetimepicker](http://www.malot.fr/bootstrap-datetimepicker/)

* TODO: more comments to the code. More tests.
