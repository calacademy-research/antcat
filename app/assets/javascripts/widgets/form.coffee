class AntCat.Form

  constructor: (@element, @options = {}) ->
    AntCat.log 'constructor: @element.size() != 1' unless @element.size() == 1
    @options.field = true unless @options.field?
    @element.addClass 'antcat_form'
    @initialize_buttons() if @needs_to_initialize_buttons_in_constructor()

  needs_to_initialize_buttons_in_constructor: => true

  form: => @element

  initialize_buttons: =>
    @options.button_container or= '> .buttons'
    @buttons = @element.find(@options.button_container)
    AntCat.log 'initialize_buttons: @buttons.size() != 1' unless @buttons.size() == 1
    @buttons
      .find(':button, :submit').unbutton().button().end()
      .find('.submit')
        .off('click')
        .on('click', @submit).end()
      .find('.cancel')
        .off('click')
        .on('click', @cancel).end()

  open: =>
    @element.show()
    @focus_initial_control()
    @options.on_open() if @options.on_open

  focus_initial_control: =>
    $control = @initial_control_to_focus()
    if $control.size() == 1
      $control.focus()
    else
      AntCat.log 'Form focus_initial_control: $control.size() != 1'
      AntCat.log $control

  initial_control_to_focus: =>
    @element.find('input[type=text]:visible:first, textarea:visible:first').first()

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

  button_selector = ':button, input[type=submit]'

  start_throbbing: =>
    @buttons.find(button_selector).disable()
    @element.find('img.throbber').show()

  stop_throbbing: =>
    @buttons.find(button_selector).undisable()
    @element.find('img.throbber').hide()

  enable_buttons: =>
    @buttons.find(button_selector).undisable()

  disable_buttons: =>
    @buttons.find(button_selector).disable()

