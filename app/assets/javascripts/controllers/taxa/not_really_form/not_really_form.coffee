# Extracted from where `AntCat.TaxonForm` is defined.
#
# For stuff that's not really part of the taxon form. This "stuff" is rendered
# on the same page as the form, and depends on the form when it shouldn't.

$ ->
  new AntCat.NotReallyTaxonForm $('.taxon_form'),
    button_container: '> .fields_section .buttons_section'

class AntCat.NotReallyTaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_history_section()
    @initialize_junior_and_senior_synonyms_section()
    @initialize_references_section()

    @initialize_events()
    @original_submit = null
    super

  ###### initialization
  initialize_history_section: =>
    new AntCat.HistoryItemsSection @element.find('.history_items_section'), parent_form: @

  initialize_junior_and_senior_synonyms_section: =>
    new AntCat.SynonymsSection @element.find('.junior_synonyms_section'), parent_form: @
    new AntCat.SynonymsSection @element.find('.senior_synonyms_section'), parent_form: @

  initialize_references_section: =>
    new AntCat.ReferencesSection @element.find('.references_section'), parent_form: @

  initialize_events: =>
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER

  taxon_id: =>
    match = @form().attr('action').match /\d+/
    match and match[0]

  ###### client functions
  replace_junior_and_senior_synonyms_section: (content) =>
    $('.junior_and_senior_synonyms_section').replaceWith content
    @initialize_junior_and_senior_synonyms_section()

  add_history_item_panel: ($panel) =>
    @element.find('.history_items').append $panel

  add_reference_panel: ($panel) =>
    @element.find('.reference_sections').append $panel

  on_form_open: =>
    super
