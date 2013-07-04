Package.on_use(function (api) {
    api.add_files('lib/model2rform/js/bootstrap-datepicker.js', 'client');
    api.add_files('lib/model2rform/js/bootstrap-datetimepicker.js', 'client');
    api.add_files('lib/model2rform/js/es-d.js', 'client');
    api.add_files('lib/model2rform/js/es-dt.js', 'client');
    api.add_files('lib/model2rform/css/datepicker.css', 'client');
    api.add_files('lib/model2rform/css/datetimepicker.css', 'client');
    api.add_files('lib/model2rform/css/rform.css', 'client');
    
    api.add_files('lib/model2rform/js/make_form.js', 'client');
    api.add_files(['lib/model2rform/js/model.js', 'lib/model2rform/js/validators.js'], ['client', 'server']);   
});
