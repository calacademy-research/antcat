window.AntCat or= {}

class AntCat.AjaxForm extends AntCat.Form

  submit: =>
    @start_throbbing()
    @form().ajaxSubmit
      beforeSerialize: ($form, options) => @before_serialize($form, options)
      beforeSubmit: ($form, options) => @before_submit($form, options)
      success: (data, statusText, xhr, $form) => @handle_response(data, statusText, xhr, $form)
      error: (jq_xhr, text_status, error_thrown) => @handle_error(jq_xhr, text_status, error_thrown)
      dataType: 'json'
    false

  before_serialize: (form, options) => true

  before_submit: (form, options) => true

  handle_response: (data, statusText, xhr, $form) =>
    @stop_throbbing()
    @options.on_response data if @options.on_response
    if data.success
      @handle_success data
    else
      @handle_application_error(data.error_message)

  handle_success: (data) =>
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

