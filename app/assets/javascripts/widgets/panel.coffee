class AntCat.Panel
  constructor: ($element, @options = {}) -> @initialize $element

  initialize: (@element) =>
    AntCat.log 'Panel ctor: no @element' unless @element.size() == 1
    @element
      .addClass(@element_class)
      .find('.display').click(@edit)
    @parent_form = new AntCat.Form @element.closest('form'), button_container: '> .buttons_section'

  edit: =>
    @save_panel()
    @show_form()
    false

  on_form_open: =>
    @parent_form.disable_buttons()

  on_form_close: =>
    @parent_form.enable_buttons()


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
    @_form or= @create_form @element.find_topmost('div.edit > .nested_form'),
      on_open: @on_form_open
      on_close: @on_form_close
      on_response: @on_form_response
      on_success: @on_form_success
      on_cancel: @on_form_cancel

  show_form: =>
    @element.find_topmost('div.display').hide()
    @element.find_topmost('div.edit').show()
    @form().open()

  hide_form: =>
    @element.find_topmost('div.edit').hide()
    @element.find_topmost('div.display').show()
    @form().close()

  is_editing: =>
    @element.find_topmost('div.edit').is ':visible'
