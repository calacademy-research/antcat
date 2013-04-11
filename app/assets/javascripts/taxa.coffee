class AntCat.TaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_add_button()
    @initialize_task_buttons()
    @initialize_junior_and_senior_synonyms_section()
    @element.bind 'keydown', @handle_event
    super

  handle_event: (event) =>
    if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER
      return false

  initialize_add_button: =>
    new AntCat.HistoryItemsSection @element.find('.history_items_section'), parent_form: @
    @add_history_item_button = @element.find '.history_section_buttons button'
    AntCat.log 'TaxonForm constructor: @add_history_item_button.size() != 1' unless @add_history_item_button.size() == 1
    @add_history_item_button.click => @add_history_item(); false

  initialize_task_buttons: =>
    @element.find('#elevate_to_species').click => @elevate_to_species(); false

  initialize_junior_and_senior_synonyms_section: =>
    new AntCat.SynonymsSection @element.find('.junior_synonyms_section'), parent_form: @
    new AntCat.SynonymsSection @element.find('.senior_synonyms_section'), parent_form: @

  replace_junior_and_senior_synonyms_section: (content) =>
    $('.junior_and_senior_synonyms_section').replaceWith content
    @initialize_junior_and_senior_synonyms_section()

  elevate_to_species: =>
    return unless confirm 'Are you sure you want to elevate this subspecies to species?'
    $('#task_button_command').val('elevate_to_species')
    @submit()

  cancel: =>
    id = @form().attr('action').match(/\d+/)[0]
    window.location = "/catalog/#{id}"

  add_history_item: =>
    AntCat.HistoryItemPanel.add_history_item @

  add_history_item_panel: ($panel) =>
    @element.find('.history_items').append $panel

$ ->
  form = new AntCat.TaxonForm $('.taxon_form'), button_container: '> .fields_section .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.NameField $('#protonym_name_field'), value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: form
  if $('#type_name_field').size() == 1
    new AntCat.NameField $('#type_name_field'), value_id: 'taxon_type_name_attributes_id', parent_form: form
    new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.ReferenceField $('#authorship_field'), parent_form: form, value_id: 'taxon_protonym_attributes_authorship_attributes_reference_attributes_id'
  $('.history_item').history_item_panel(click_on_display: true, parent_form: form)
