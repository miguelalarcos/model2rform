// Generated by CoffeeScript 1.6.1
(function() {
  var Search, checked, eq, gt, gte, indeterminate, lt, lte, make_search, on_change, on_change_bool, on_change_generic, rotate_checkbox, unchecked;

  checked = "x";

  unchecked = " ";

  indeterminate = "--";

  Search = (function() {

    function Search() {}

    Search.constructor = function(obj) {
      var attr, _i, _len, _ref;
      _ref = this._attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        obj['_error_' + attr] = '';
      }
      return obj;
    };

    return Search;

  })();

  eq = function(value) {
    if (value === '') {
      return null;
    }
    return value;
  };

  gt = function(value) {
    if (value === '') {
      return null;
    }
    return {
      "$gt": value
    };
  };

  gte = function(value) {
    if (value === '') {
      return null;
    }
    return {
      "$gte": value
    };
  };

  lt = function(value) {
    if (value === '') {
      return null;
    }
    return {
      "$lt": value
    };
  };

  lte = function(value) {
    if (value === '') {
      return null;
    }
    return {
      "$lte": value
    };
  };

  rotate_checkbox = function(cb) {
    var data, el;
    el = $(cb);
    data = el.text();
    switch (data) {
      case indeterminate:
        return false;
      case unchecked:
        return true;
      default:
        return null;
    }
  };

  on_change = function(search_name, klass, name, value) {
    var obj;
    console.log(name, value);
    obj = Session.get(search_name + '_object');
    try {
      klass[name][0](value);
      obj['_error_' + name] = '';
    } catch (error) {
      obj['_error_' + name] = error;
    }
    obj[name] = value;
    return Session.set(search_name + '_object', obj);
  };

  on_change_bool = function(search_name, klass) {
    return function(e, t) {
      var name, value;
      value = rotate_checkbox(e.target);
      name = $(e.target).attr('name');
      return on_change(search_name, klass, name, value);
    };
  };

  on_change_generic = function(search_name, klass) {
    return function(e, t) {
      var name, value;
      name = $(e.target).attr('name');
      value = $(e.target).val();
      return on_change(search_name, klass, name, value);
    };
  };

  make_search = function(template, search_name, klass) {
    var dct, yet_rendered;
    Session.set(search_name + '_object', klass.constructor({}));
    template.objeto = function() {
      return Session.get(search_name + '_object');
    };
    dct = {};
    dct['mouseup #' + search_name + '_search'] = function(e, t) {
      var attr, obj, selector, value, _i, _len, _ref;
      selector = {};
      obj = Session.get(search_name + '_object');
      _ref = klass._attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        value = obj[attr];
        if (value !== '' && value !== null && value !== void 0) {
          value = klass[attr][0](value);
          if (moment.isMoment(value)) {
            value = value.toDate();
          }
          value = klass[attr][1](value);
          selector[attr] = value;
        }
      }
      console.log(selector);
      return Session.set(search_name + '_selector', selector);
    };
    dct['input .' + search_name + '_attr'] = on_change_generic(search_name, klass);
    dct['click .' + search_name + '_attr_bool'] = on_change_bool(search_name, klass);
    dct['change .' + search_name + '_attr_select'] = on_change_generic(search_name, klass);
    template.events = dct;
    template.format_date = function(format, fecha) {
      if (fecha) {
        fecha = moment(fecha);
        return fecha.format(format);
      }
    };
    template.disabled = function() {
      var attr, obj, _i, _len, _ref;
      obj = Session.get(search_name + '_object');
      _ref = klass._attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (obj['_error_' + attr] !== '') {
          return 'disabled';
        }
      }
      return '';
    };
    template.checked = function(value) {
      console.log('template.checked', value);
      if (value === null || value === void 0) {
        return indeterminate;
      }
      if (value) {
        return checked;
      } else {
        return unchecked;
      }
    };
    yet_rendered = false;
    return template.rendered = function() {
      var d, d_, dt, dt_, for_rendered, selector;
      if (!yet_rendered) {
        yet_rendered = true;
        for_rendered = klass._for_rendered;
        for (d in for_rendered['date']) {
          d_ = '#' + search_name + ' input[name=' + d + ']';
          $(d_).datepicker({
            format: for_rendered['date'][d],
            autoclose: true
          });
        }
        selector = '.' + search_name + '_attr_date';
        $(selector).on('changeDate', on_change_generic(search_name, klass));
        for (dt in for_rendered['datetime']) {
          dt_ = '#' + search_name + ' input[name="' + dt + '"]';
          $(dt_).datetimepicker({
            format: for_rendered['datetime'][dt],
            autoclose: true
          });
        }
        selector = '.' + search_name + '_attr_datetime';
        return $(selector).on('changeDate', on_change_generic(search_name, klass));
      }
    };
  };

  this.model2rform_search = {
    gt: gt,
    gte: gte,
    eq: eq,
    lte: lte,
    lt: lt,
    make_search: make_search,
    Search: Search
  };

}).call(this);