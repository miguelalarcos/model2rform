Package.on_use(function (api) {
    api.add_files('make_form.js', 'client');
    api.add_files(['model.js', 'validators.js'], ['client', 'server']);   
});
