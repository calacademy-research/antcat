class AntCat.ReferencesSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    @initialize_add_button()
    @initialize_panels()

  initialize_add_button: =>
    $add_button = @element.find '.references_section_buttons button'
    $add_button.click => @add(); false

  add: =>
    AntCat.ReferencesSectionPanel.add_reference @options.parent_form

  initialize_panels: =>
    @element.find('.reference_sections .reference_section').references_section_panel(click_on_display: true, parent_form: @options.parent_form)

#####
$.fn.references_section_panel = (options = {}) ->
  this.each -> new AntCat.ReferencesSectionPanel $(this), options

class AntCat.ReferencesSectionPanel extends AntCat.Panel
  constructor: (@element, @options) ->
    @options.click_on_display = true
    @options.highlight = true
    super

  initialize: (@element) =>
    super
    @make_references_edit_field_same_height_as_when_displayed()

  make_references_edit_field_same_height_as_when_displayed: =>
    $display_field = @element.find '.display > .references_taxt'
    edit_height = Math.max($display_field.height() + 24, 100)
    $edit_field = @element.find('#references_taxt')
    $edit_field.height edit_height unless edit_height is 0

  create_form: ($element, options) -> new AntCat.ReferencesSectionForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea:first').focus()
    super

  @add_reference: (form) =>
    $template = $('.reference_section_template').clone()
    $item = $template.find('.reference_section')
    $item.removeClass('reference_section_template').addClass('added_reference')
    form.add_reference_panel $item
    $item.references_section_panel click_on_display: true, parent_form: form, open_immediately: true

#####
class AntCat.ReferencesSectionForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super
    @element.find('#title_taxt').parent().taxt_editor(parent_buttons: '.buttons_section')
    @element.find('#subtitle_taxt').parent().taxt_editor(parent_buttons: '.buttons_section')
    @element.find('#references_taxt').parent().taxt_editor(parent_buttons: '.buttons_section')

  initialize_buttons: =>
    super
    @buttons.find('.delete').off('click').on('click', @delete)

  initial_control_to_focus: => null

  delete: =>
    return false unless confirm 'Do you want to delete this reference section?'
    @start_throbbing()
    url = @form().attr('action')
    $.post url, {_method: 'delete'}, null, 'json'
    @close()
    @options.on_delete() if @options.on_delete
    @element.closest('.reference_section').remove()
    false

  cancel: =>
    $('.added_reference').remove()
    super

  close: =>
    $('.added_reference').removeClass('.added_reference')
    super
