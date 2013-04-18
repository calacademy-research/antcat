class AntCat.ReferencesSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    @initialize_add_button()
    @initialize_panels()

  initialize_add_button: =>
    $add_button = @element.find '.references_section_buttons button'; AntCat.log 'ReferencesSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
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
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height() + 24
    $tall_field = $('#references_taxt')
    AntCat.log 'ReferencesSectionPanel initialize: no $tall_field' unless $tall_field && $tall_field.size() == 1
    @element.find('#references_taxt').height(display_height) unless display_height is 0

  create_form: ($element, options) -> new AntCat.ReferencesSectionForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea:first').focus()
    super

  @add_reference: (form) =>
    $template = $('.reference_section_template').clone()
    AntCat.log 'ReferencesSectionPanel add_reference: no $template' unless $template && $template.size() == 1
    $item = $template.find('.reference_section')
    AntCat.log 'ReferencesSectionPanel add_reference: no $item' unless $item && $item.size() == 1
    $item.removeClass('template').addClass('added_reference')
    form.add_reference_panel $item
    $item.references_section_panel click_on_display: true, parent_form: form, open_immediately: true

#####
class AntCat.ReferencesSectionForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super
    @element.find('.taxt_editor').taxt_editor()

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
