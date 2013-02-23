class AntCat.ReferenceFieldPanel
  constructor: ($element, @options = {}) ->
    @initialize $element

  initialize: (@element) =>
    AntCat.log 'ReferenceFieldPanel initialize: no @element' unless @element && @element.size() == 1
    @setup_sections()
    @setup_edit()

  setup_sections: =>
    edit_selector = @options.edit_selector || '> .edit'
    @edit = @element.find edit_selector
    AntCat.log 'ReferenceFieldPanel setup_sections: no @edit' unless @edit.size() == 1

    display_selector = @options.display_selector || '> .display'
    @display = @element.find display_selector
    AntCat.log 'ReferenceFieldPanel setup_sections: no @display' unless @display.size() == 1

  setup_edit: =>
    $edit_icon = @element.find '.icon.edit'
    if @options.click_on_display
      console.log 'display click'
      @display.click @edit
    else
      @element
        .mouseenter(=> $edit_icon.show() unless @is_editing())
        .mouseleave(=> $edit_icon.hide())
      $edit_icon.click(@edit)

  edit: =>
    @save_panel()
    @show_form()
    false

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
    @display.hide()
    @edit.show()
    @form().open()

  hide_form: =>
    @edit.hide()
    @display.show()
    @form().close()

  is_editing: =>
    @edit.is ':visible'
