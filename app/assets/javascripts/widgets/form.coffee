window.AntCat or= {}

class AntCat.Form

  constructor: (@element, @options = {}) ->
    @options.field = true unless @options.field?
    @options.button_container or= '> .buttons'
    @element.addClass 'antcat_form'
    @initialize_buttons()

  initialize_buttons: =>
    @buttons = @element.find(@options.button_container)
    @buttons
      .find(':button, :submit').unbutton().button().end()
      .find('.submit').click(@submit).end()
      .find('.cancel').click(@cancel).end()
      .end()

  open: =>
    @element.show() unless @options.field
    @element.find('input[type=text]:visible:first').focus()
    @options.on_open() if @options.on_open

  close: =>
    @element.slideUp('fast', =>) unless @options.field
    @options.on_close() if @options.on_close

  submit: =>
    @start_throbbing()
    @element.find('.edit form').ajaxSubmit
      success: (data, statusText, xhr, $form) => @handle_response(data, statusText, xhr, $form)
      error: (jq_xhr, text_status, error_thrown) => @handle_error(jq_xhr, text_status, error_thrown)
      dataType: 'json'
    false

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    @close()
    false

  handle_response: (data, statusText, xhr, $form) =>
    @stop_throbbing()
    @options.on_response data if @options.on_response
    if data.success
      @handle_success()
    else
      @handle_application_error(data.error_message)

  handle_success: =>
    @options.on_success data if @options.on_success
    @close()

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

