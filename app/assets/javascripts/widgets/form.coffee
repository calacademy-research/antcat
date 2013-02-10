window.AntCat or= {}

class AntCat.Form

  constructor: (@element, @options = {}) ->
    @options.field = true unless @options.field?
    @element.addClass 'antcat_form'
    @initialize_buttons() if @needs_to_initialize_buttons_in_constructor()

  needs_to_initialize_buttons_in_constructor: => true

  form: => @element

  initialize_buttons: =>
    @options.button_container or= '> .buttons'
    @buttons = @element.find(@options.button_container)
    console.log 'initialize_buttons: @buttons is nil' unless @buttons.size() == 1
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
    @element.hide() unless @options.field
    @options.on_close() if @options.on_close

  submit: =>
    @start_throbbing()
    @form().submit()
    false

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    @close()
    false

  start_throbbing: =>
    @buttons.find(':button, input[type=submit]').disable()
    @element.find('img.throbber').show()

  stop_throbbing: =>
    @buttons.find(':button, :input[type=submit]').undisable()
    @element.find('img.throbber').hide()

