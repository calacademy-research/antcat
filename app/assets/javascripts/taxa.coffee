class AntCat.TaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_add_button()
    @initialize_task_buttons()
    @initialize_synonyms()
    super

  initialize_add_button: =>
    @add_history_item_button = @element.find '.history_section_buttons button'
    AntCat.log 'TaxonForm constructor: @add_history_item_button.size() != 1' unless @add_history_item_button.size() == 1
    @add_history_item_button.click => @add_history_item(); false

  initialize_task_buttons: =>
    @element.find('#reverse_synonymy').click => @reverse_synonymy(); false
    @element.find('#elevate_to_species').click => @elevate_to_species(); false

  initialize_synonyms: =>
    @element.find('button.delete').show() if AntCat.testing
    $delete_buttons = @element.find '.junior_and_senior_synonyms_section button.delete'
    AntCat.log 'TaxonForm initialize_synonyms: $delete_buttons.size() < 1' unless $delete_buttons.size() >= 1
    $delete_buttons.click (event) => @delete_synonym(event.target); false
    @element.find('.synonym_row').hover(
      (event) =>
        $(event.target).closest('.synonym_row')
          .select()
          .find('.delete').show().end()
      (event) =>
        AntCat.deselect()
        $delete_buttons.hide()
    )

  delete_synonym: (target) =>
    return unless confirm 'Are you sure you want to delete this synonym?'
    taxon_id = $(target).data('taxon-id')
    synonym_id = $(target).data('synonym-id')
    url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}"
    $.post url, {_method: 'delete'}, null, 'json'
    $(target).closest('.synonym_row').remove()

  reverse_synonymy: =>
    return unless confirm 'Are you sure you want to reverse the synonymy?'
    $('#task_button_command').val('reverse_synonymy')
    @submit()

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
  form = new AntCat.TaxonForm $('.taxon_form'), button_container: '> .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.NameField $('#protonym_name_field'), value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: form
  if $('#type_name_field').size() == 1
    new AntCat.NameField $('#type_name_field'), value_id: 'taxon_type_name_attributes_id', parent_form: form
    new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.ReferenceField $('#authorship_field'), parent_form: form, value_id: 'taxon_protonym_attributes_authorship_attributes_reference_attributes_id'
  $('.history_item').history_item_panel(click_on_display: true, parent_form: form)
  new AntCat.SynonymsSection $('.junior_synonyms_section')
  new AntCat.SynonymsSection $('.senior_synonyms_section')
