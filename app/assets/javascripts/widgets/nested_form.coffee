window.AntCat or= {}

$.fn.nested_form = ->
  return this.each -> new AntCat.NestedForm $(this)

class AntCat.NestedForm
  constructor: ($element, @options = {}) -> @initialize $element

  initialize: ($element) =>
    self = @
    @element = $element
    @element
      .addClass('nested_form')
      .find('> .submit')
        .button()
        .click -> self.submit(this)
        .end()
      .find('> .cancel')
        .button()
        .click(@cancel)
        .end()

  submit: (button) =>
    @start_spinning()
    console.log 'submitting'
    $nested_form = $(button).closest('.nested_form').clone()
    $nested_form.find('.nested_form').remove()
    $form = $('<form/>')
    $form.html $nested_form
    $form.action = '/widget_tests/nested_form'
    $form.ajaxSubmit
      success: -> console.log 'success'
      error: (jq_xhr, text_status, error_thrown) ->
        console.log error_thrown
      type: 'POST'
    false

  open: =>
    @element.find('input[type=text]:visible:first').focus()
    @options.on_open() if @options.on_open

  close: => @options.on_close() if @options.on_close

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    false

  update: (data, statusText, xhr, $form) =>
    @stop_spinning()
    @options.on_update data
    @options.on_done data if data.success and @options.on_done

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: AntCat.spinner_path

  stop_spinning: =>
    @element.find('.spinner').spinner 'remove'
    @element.find(':button').undisable()

  before_serialize: ($form, options) => true
