$ -> new AntCat.TaxonForm $('.taxon_form'), button_container: '> .fields_section .buttons_section'

class AntCat.TaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_fields_section()
    @initialize_history_section()
    @initialize_junior_and_senior_synonyms_section()
    @initialize_references_section()
    @initialize_task_buttons()
    @initialize_events()
    super

  ###### initialization
  initialize_fields_section: =>
    new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
    new AntCat.NameField $('#protonym_name_field'), value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: @
    new AntCat.NameField $('#homonym_replaced_by_name_field'), value_id: 'taxon_homonym_replaced_by_name_attributes_id', parent_form: @
    if $('#type_name_field').size() == 1
      new AntCat.NameField $('#type_name_field'), value_id: 'taxon_type_name_attributes_id', parent_form: @
      new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
    new AntCat.ReferenceField $('#authorship_field'), parent_form: @, value_id: 'taxon_protonym_attributes_authorship_attributes_reference_attributes_id'

  initialize_history_section: =>
    new AntCat.HistoryItemsSection @element.find('.history_items_section'), parent_form: @

  initialize_junior_and_senior_synonyms_section: =>
    new AntCat.SynonymsSection @element.find('.junior_synonyms_section'), parent_form: @
    new AntCat.SynonymsSection @element.find('.senior_synonyms_section'), parent_form: @

  initialize_references_section: =>
    new AntCat.ReferencesSection @element.find('.references_section'), parent_form: @

  initialize_task_buttons: =>
    @element.find('#elevate_to_species').click => @elevate_to_species(); false

  initialize_events: =>
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER

  ###### overrides
  cancel: =>
    id = @form().attr('action').match(/\d+/)[0]
    window.location = "/catalog/#{id}"

  ###### client functions
  replace_junior_and_senior_synonyms_section: (content) =>
    $('.junior_and_senior_synonyms_section').replaceWith content
    @initialize_junior_and_senior_synonyms_section()

  elevate_to_species: =>
    return unless confirm 'Are you sure you want to elevate this subspecies to species?'
    $('#task_button_command').val('elevate_to_species')
    @submit()

  add_history_item_panel: ($panel) =>
    @element.find('.history_items').append $panel

  add_reference_panel: ($panel) =>
    @element.find('.reference_sections').append $panel

