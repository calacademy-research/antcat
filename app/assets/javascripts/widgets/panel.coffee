class AntCat.Panel
  constructor: (@element, @options = {}) ->
    @_post_constructor(@element, @options)

  _post_constructor: (@element, @options) =>
    @initialize @element
    if @options.open_immediately
      @edit()

  initialize: (@element) =>
    edit_selector = @options.edit_selector || '> .edit'
    @edit_section = @element.find edit_selector

    display_selector = @options.display_selector || '> .display'
    @display_section = @element.find display_selector

    @_form = null
    if @options.click_on_display
      @element.find('.display').click @edit
    if @options.click_on_icon
      $edit_icon = @element.find '.edit_icon'
      $edit_icon.click @edit
      @element
        .mouseenter(@show_edit_icon)
        .mouseleave(@hide_edit_icon)
    if @options.highlight
      @element.find('.display').hover(
        (event) => $(event.target).select(),
        (event) => AntCat.deselect()
      )

  string_value: =>
    @element.find('#name_string').val()

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
    @options.on_form_close() if @options.on_form_close

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
    @initialize $content

  save_panel: =>
    @saved_content = @element.get(0).outerHTML

  restore_panel: =>
    @replace_panel @saved_content

  form: =>
    @_form or= @create_form @element.find('.nested_form:first'),
      on_open:              @on_form_open
      on_close:             @on_form_close
      on_response:          @on_form_response
      on_success:           @on_form_success
      on_cancel:            @on_form_cancel
      on_application_error: @on_application_error
      before_submit:        @before_submit

  find_topmost: (element, selector) =>
    all_elements = element.find(selector)
    all_elements.filter -> not all_elements.is $(element).parents()

  show_form: =>
    @find_topmost(@element, 'div.display').hide()
    @find_topmost(@element, 'div.edit').show()
    @form().open()

  hide_form: =>
    @find_topmost(@element, 'div.edit').hide()
    @find_topmost(@element, 'div.display').show()
    @form().close()

  is_editing: =>
    @element.find('div.edit').is ':visible'
