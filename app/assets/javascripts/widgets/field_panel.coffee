# Options: edit_selector, display_selector
# Panel options: click_on_display, click_on_icon, highlight, parent_form

class AntCat.FieldPanel extends AntCat.Panel
  constructor: (@element, @options = {}) ->
    @options.click_on_display = true
    super

  initialize: (@element) =>
    AntCat.log 'FieldPanel initialize: no @element' unless @element && @element.size() == 1
    @setup_sections()
    @setup_edit()

  setup_sections: =>
    edit_selector = @options.edit_selector || '> .edit'
    @edit_section = @element.find edit_selector
    AntCat.log 'FieldPanel setup_sections: no @edit_section' unless @edit_section.size() == 1

    display_selector = @options.display_selector || '> .display'
    @display_section = @element.find display_selector
    AntCat.log 'FieldPanel setup_sections: no @display_section' unless @display_section.size() == 1

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
