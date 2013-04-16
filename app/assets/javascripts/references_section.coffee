class AntCat.ReferencesSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    $add_button = @element.find '.references_section_buttons button'
    AntCat.log 'ReferencesSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false
    @element.find('.reference_section').reference_panel(click_on_display: true, parent_form: @options.parent_form)

  add: =>
    AntCat.ReferencePanel.add_reference @options.parent_form

#####
$.fn.reference_panel = (options = {}) ->
  this.each -> new AntCat.ReferencePanel $(this), options

class AntCat.ReferencePanel extends AntCat.Panel
  constructor: (@element, @options) ->
    @options.click_on_display = true
    @options.highlight = true
    super

  initialize: (@element) =>
    super
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height() + 24
    @element.find('.taxt_edit_box').height(display_height) unless display_height is 0

  create_form: ($element, options) -> new AntCat.ReferenceForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea:first').focus()
    super

  @add_reference: (form) =>
    $template = $('.reference_section_template').clone()
    AntCat.log 'ReferencePanel add_reference: no $template' unless $template && $template.size() == 1
    $item = $template.find('.reference_section')
    AntCat.log 'ReferencePanel add_reference: no $item' unless $item && $item.size() == 1
    $item.removeClass('template').addClass('added_reference')
    form.add_reference_panel $item
    $item.reference_panel(click_on_display: true, parent_form: form, open_immediately: true)

#####
class AntCat.ReferenceForm extends AntCat.NestedForm
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
