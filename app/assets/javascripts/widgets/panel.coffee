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
    @form = @create_form @element.find('div.edit form'), on_update: @on_edit_update, on_done: @on_edit_done, on_cancel: @on_edit_cancelled

  edit: =>
    return if @is_editing()
    @show_form()
    false


  on_edit_done: (new_content) =>
    id = @element.data 'id'
    @element.replaceWith new_content
    @initialize $(".item_#{id}")

  on_edit_cancelled: =>
  show_form: =>
    $('.icon').hide() unless AntCat.testing
    @element.find('div.display').hide()
    @element.find('div.edit').show()

    @element.find('div.edit').hide()
    @element.find('div.display').show()

  is_editing: => @form.is_editing()
  @is_editing: -> $(".#{@element_class} .antcat_form:first").is ':visible'
