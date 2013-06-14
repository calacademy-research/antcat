# Options: edit_selector, display_selector
# Panel options: click_on_display, click_on_icon, highlight, parent_form

class AntCat.FieldPanel extends AntCat.Panel
  _post_constructor: (@element, @options = {}) =>
    @options.click_on_display = true
    super

  initialize: (@element) =>
    @setup_sections()
    @setup_edit()

  setup_sections: =>
    edit_selector = @options.edit_selector || '> .edit'
    @edit_section = @element.find edit_selector

    display_selector = @options.display_selector || '> .display'
    @display_section = @element.find display_selector

  setup_edit: =>
    @display_section.click @edit

  show_form: =>
    @display_section.hide()
    @edit_section.show()
    @form().open()

  hide_form: =>
    @edit_section.hide()
    @display_section.show()
    @form().close()

  is_editing: =>
    @edit_section.is ':visible'
