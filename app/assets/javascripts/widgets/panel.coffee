class AntCat.Panel
  constructor: ($element, @options = {}) ->
    @initialize $element

  initialize: (@element) =>
    AntCat.log 'Panel initialize: no @element' unless @element && @element.size() == 1
    @setup_edit()

  setup_edit: =>
    if @options.click_on_display
      @element.find('.display').click @edit
    if @options.click_on_icon
      $edit_icon = @element.find '.edit_icon'
      AntCat.log 'Panel setup_edit: no $edit_icon' unless $edit_icon && $edit_icon.size() >= 1
      $edit_icon.click @edit
      @element
        .mouseenter(@show_edit_icon)
        .mouseleave(@hide_edit_icon)
    if @options.highlight
      @element.find('.display').hover(
        (event) => $(event.target).select(),
        (event) => AntCat.deselect()
      )

  edit: =>
    @save_panel()
    @show_form()
    false

  show_edit_icon: => @element.find('.edit_icon').show() unless @is_editing()
  hide_edit_icon: => @element.find('.edit_icon').hide()

  on_form_open: =>
    @options.parent_form.disable_buttons() if @options.parent_form

  on_form_close: =>
    @options.parent_form.enable_buttons() if @options.parent_form

  on_form_response: (data) =>
    @replace_panel data.content
    if data.success then @hide_form() else @show_form()

  on_form_done: (data) =>

  on_form_cancel: =>
    @restore_panel()
    @hide_form()

  replace_panel: (content) =>
    $content = $(content)
    @element.replaceWith $content
    @_form = null
    @initialize $content

  save_panel: =>
    @saved_content = @element.get(0).outerHTML

  restore_panel: =>
    @replace_panel @saved_content

  form: =>
    @_form or= @create_form @element.find('.nested_form'),
      on_open:              @on_form_open
      on_close:             @on_form_close
      on_response:          @on_form_response
      on_success:           @on_form_success
      on_cancel:            @on_form_cancel
      on_application_error: @on_application_error
      before_submit:        @before_submit

  show_form: =>
    @element.find_topmost('div.display').hide()
    @element.find_topmost('div.edit').show()
    @form().open()

  hide_form: =>
    @element.find_topmost('div.edit').hide()
    @element.find_topmost('div.display').show()
    @form().close()

  is_editing: =>
    @element.find('div.edit').is ':visible'
