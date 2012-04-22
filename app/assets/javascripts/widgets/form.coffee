window.AntCat or= {}

class AntCat.Form

  constructor: (@element, options = {}) ->
    @element.addClass 'antcat_form'
    @on_done = options.on_done
    @on_cancel = options.on_cancel
    @save_form_values()
    @spinner_path = 'assets/ui-anim_basic_16x16.gif'
    (new Image()).src = @spinner_path
    self = @
    @element
      .find('.submit')
        .button()
        .click(-> self.submit_form this)
        .end()
      .find('.cancel')
        .button()
        .click(-> self.cancel_form this)
        .end()

      .find('textarea')
        .taxt_edit_box()
        .end()
      .find('.taxt_edit_box').first()
        .focus()

  submit_form: (button) =>
    @start_spinning()
    @element.ajaxSubmit
      success: @update_form
      error: @handle_error
      dataType: 'json'
    false

  update_form: (data, statusText, xhr, $form) =>
    @stop_spinning()
    panel_selector = '#item_' + (if data.isNew then "" else data.id)
    $panel = $ panel_selector
    if not data.success
      @show_error_messages data.content
      return
    @on_done panel_selector, data.content

  cancel_form: (button) =>
    @clear_error_messages()
    @restore_form_values() unless @is_new_item()
    @on_cancel() if @on_cancel
    false

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: @spinner_path

  stop_spinning: =>
    @element.find('.spinner')
      .enable()
      .spinner 'remove'

  show_error_messages: (html) ->
    clear_error_messages()
    @element.prepend $(html).find 'ul.error_messages'

  clear_error_messages: =>
    @element.find('ul.error_messages').remove()

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  is_new_item: =>
    false #@element.attr('id') is 'item_'
