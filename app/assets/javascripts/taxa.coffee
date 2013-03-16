class AntCat.TaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @add_history_item_button = @element.find '.history_section_buttons button'
    AntCat.log 'TaxonForm constructor: @add_history_item_button.size() != 1' unless @add_history_item_button.size() == 1
    @add_history_item_button.click -> @add_history_item(); false
    super

  submit: =>
    @start_throbbing()
    @form().submit()

  cancel: =>
    id = @form().attr('action').match(/\d+/)[0]
    window.location = "/catalog/#{id}"

  add_history_item: =>

$ ->
  form = new AntCat.TaxonForm $('.taxon_form'), button_container: '> .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.NameField $('#protonym_name_field'), value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: form
  new AntCat.NameField $('#type_name_field'), value_id: 'taxon_type_name_attributes_id', parent_form: form
  new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.ReferenceField $('#authorship_field'), parent_form: form, value_id: 'taxon_protonym_attributes_authorship_attributes_reference_attributes_id'
  $('.history_item').history_item_panel(click_on_display: true, parent_form: form)
