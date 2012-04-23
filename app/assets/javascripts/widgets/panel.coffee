window.AntCat or= {}

class AntCat.Panel

  constructor: ($element, @options = {}) -> @initialize $element

  initialize: ($element) =>
    console.log $element.attr 'class'
    @element = $element
    @element
      .addClass(@element_class)
      .mouseenter(=> @element.find('.icon').show())
      .mouseleave(=> @element.find('.icon').hide())
      .find('.icon.edit').click(@edit)
    @element.find('.icon').hide() unless AntCat.testing

  edit: =>
    return if @is_editing()
    $('.icon').hide() unless AntCat.testing
    @element.find('div.display').hide()
    @element.find('div.edit').show()
    @create_form @element.find('div.edit form'), on_done: @on_edit_done, on_cancel: @on_edit_cancelled
    @setup_form()
    @options.on_edit_opened() if @options.on_edit_opened
    false

  setup_form: =>

  on_edit_done: (new_content) =>
    id = @element.data 'id'
    @element.replaceWith new_content
    @initialize $(".item_#{id}")

  on_edit_cancelled: =>
    @element.find('div.edit').hide()
    @element.find('div.display').show()

  @is_editing: -> $(".#{@element_class} .antcat_form:first").is ':visible'
  is_editing: => false #@element.find('.antcat_form:first').is ':visible'
