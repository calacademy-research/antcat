window.AntCat or= {}

class AntCat.Form
  @css_class = 'antcat_form'

  constructor: (@element, @options = {}) ->
    @options.button_container or= '> .buttons'
    @element.addClass(AntCat.Form.css_class)
    @buttons = @element.find(@options.button_container)
    @buttons
      .find(':button, :submit').unbutton().button().end()
      .find('.submit').click(@submit).end()
      .find('.cancel').click(@cancel).end()
      .end()

  open: =>
    @element.show() if @options.modal
    @element.find('input[type=text]:visible:first').focus()
    @options.on_open() if @options.on_open

  close: =>
    @element.hide() if @options.modal
    @options.on_close() if @options.on_close

  submit: =>
    @start_throbbing()
    @form().ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update
      error: @handle_error
      dataType: 'json'
    false

  form: => @element

  before_serialize: ($form, options) =>
    return @options.before_serialize($form, options) if @options.before_serialize
    true

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    @close()
    false

  update: (data, statusText, xhr, $form) =>
    @stop_throbbing()
    @options.on_update data if @options.on_update
    if data.success
      @options.on_done data if @options.on_done
      @close()
    else
      @handle_application_error(data.error_message)

  handle_application_error: (error_message) =>
    @options.on_application_error error_message if @options.on_application_error

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_throbbing()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_throbbing: =>
    @buttons.find(':button, input[type=submit]').disable()
    @element.find('img.throbber').show()

  stop_throbbing: =>
    @buttons.find(':button, :input[type=submit]').undisable()
    @element.find('img.throbber').hide()

