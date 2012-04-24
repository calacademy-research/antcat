window.AntCat or= {}

class AntCat.Panel
  constructor: ($element) -> @initialize $element

  initialize: ($element) =>
    @element = $element
    @element
      .addClass(@element_class)
      .mouseenter(=> @element.find('.icon').show() unless @is_editing())
      .mouseleave(=> @element.find('.icon').hide())
      .find('.icon.edit').click(@edit)
    @element.find('.icon').hide() unless AntCat.testing
    @create_form @element.find('div.edit form'),
      on_update: @on_edit_update
      on_done: @on_edit_done
      on_cancel: @on_edit_cancelled

  edit: =>
    @save_panel()
    @show_form()
    false

  on_edit_update: (new_content, error) =>
    @replace_panel new_content
    if error then @show_form() else @hide_form()

  on_edit_cancelled: =>
    @restore_panel()
    @hide_form()

  replace_panel: (content) =>
    id = @element.data 'id'
    @element.replaceWith content
    @initialize $(".item_#{id}")

  save_panel: =>
    @saved_content = @element.get(0).outerHTML

  restore_panel: =>
    @replace_panel @saved_content

  show_form: =>
    $('.icon').hide() unless AntCat.testing
    @element.find('div.display').hide()
    @element.find('div.edit').show()

  hide_form: =>
    @element.find('div.edit').hide()
    @element.find('div.display').show()

  is_editing: => @element.find('div.edit').is ':visible'
  @is_editing: -> $(".#{@element_class} .antcat_form:first").is ':visible'
