window.AntCat or= {}

$.fn.nested_form = (options = {}) ->
  this.each -> new AntCat.NestedForm $(this, options)

class AntCat.NestedForm
  constructor: ($element, @options = {}) -> @initialize $element

  initialize: ($element) =>
    self = @
    @element = $element
    @element
      .addClass('nested_form')
      .find('button.submit')
        .button()
        .click(-> self.submit this)
        .end()
      .find('button.cancel')
        .button()
        .click(@cancel)
        .end()

  open: =>
    @element.find('input[type=text]:visible:first').focus()
    @options.on_open() if @options.on_open

  close: => @options.on_close() if @options.on_close

  submit: (button) =>
    @start_spinning()
    $form = @convert_to_form()
    $form.ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update
      error: @handle_error
      dataType: 'json'
    false

  convert_to_form: =>
    $nested_form = @element.clone()
    $nested_form.find('.nested_form').remove()
    $form = $('<form/>')
    $form.html $nested_form
    $form.attr 'action', $nested_form.data 'action'
    $form.attr 'method', $nested_form.data 'method'
    $form

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    @close()
    false

  update: (data, statusText, xhr, $form) =>
    @stop_spinning()
    @options.on_update data if @options.on_update
    @options.on_done data if data.success and @options.on_done
    @close() if data.success

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: AntCat.spinner_path

  stop_spinning: =>
    @element.find('.spinner').spinner 'remove'
    @element.find('.buttons :button').undisable()

  before_serialize: ($form, options) =>
    return @options.before_serialize($form, options) if @options.before_serialize
    true
