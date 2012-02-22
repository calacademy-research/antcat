function setupQtip(selector, text, options) {

  options = options || {};
  options.content = text;
  options.show = 'mouseover';
  options.hide = 'mouseout';
  options.style = options.style || {};
  options.style.name = 'dark';

  $(selector).qtip(options);
}

