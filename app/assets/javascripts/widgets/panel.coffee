window.AntCat or= {}

class AntCat.Panel
  constructor: ($element, @options = {}) -> @initialize $element

  initialize: ($element) =>
    @element = $element
    @element
      .addClass(@element_class)
      .mouseenter(=> @element.find('.icon').show() unless @is_editing())
      .mouseleave(=> @element.find('.icon').hide())
      .find('.icon.edit').click(@edit)
    @form = @create_form @element.find('div.edit form'),
      on_open: @on_form_open
      on_close: @on_form_close
      on_update: @on_form_update
      on_done: @on_form_done
      on_cancel: @on_form_cancel
    $('.icon').show() if AntCat.testing

  edit: =>
    @save_panel()
    @show_form()
    false

  on_form_open: =>

  on_form_close: =>

  on_form_update: (data) =>
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

  show_form: =>
    $('.icon').hide() unless AntCat.testing
    @element.find('div.display').hide()
    @element.find('div.edit').show()
    @form.open()

  hide_form: =>
    @element.find('div.edit').hide()
    @element.find('div.display').show()
    @form.close()

  is_editing: => @element.find('div.edit').is ':visible'
  @is_editing: -> $(".#{@element_class} .antcat_form:first").is ':visible'
