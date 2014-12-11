$ -> new AntCat.TaxonForm $('.taxon_form'), button_container: '> .fields_section .buttons_section'

class AntCat.ProtonymField extends AntCat.NameField
  constructor: ($parent_element, @name_field, @options = {}) ->
    super $parent_element, @options
  get_default_name_string: =>
    @name_field.string_value()

class AntCat.TypeNameField extends AntCat.NameField
  constructor: ($parent_element, @protonym_field, @options = {}) ->
    super $parent_element, @options
  get_default_name_string: =>
    string = @protonym_field.string_value()
    return unless string
    string + ' '

class AntCat.TaxonForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_fields_section()
    @initialize_parent_section()
    @initialize_current_valid_taxon_section()
    @initialize_history_section()
    @initialize_junior_and_senior_synonyms_section()
    @initialize_references_section()
    @initialize_current_valid_taxon_section()
    @initialize_homonym_replaced_by_section()
    @initialize_task_buttons()
    @initialize_events()
    @initialize_duplicate_handler()
    @original_submit = null

    super



  ###### initialization
  initialize_fields_section: =>
    name_field = new AntCat.NameField $('#name_field'), value_id: 'taxon_name_attributes_id', parent_form: @, new_or_homonym: true
    new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
    new AntCat.TaxtEditor $('#notes_taxt_editor'), parent_buttons: '.buttons_section'
    protonym_field = new AntCat.ProtonymField $('#protonym_name_field'), name_field, value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: @
    if $('#type_name_field').size() == 1
      new AntCat.TypeNameField $('#type_name_field'), protonym_field, value_id: 'taxon_type_name_attributes_id', parent_form: @, allow_blank: true
      new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
    new AntCat.ReferenceField $('#authorship_field'), parent_form: @, value_id: 'taxon_protonym_attributes_authorship_attributes_reference_attributes_id'

  initialize_history_section: =>
    new AntCat.HistoryItemsSection @element.find('.history_items_section'), parent_form: @

  initialize_junior_and_senior_synonyms_section: =>
    new AntCat.SynonymsSection @element.find('.junior_synonyms_section'), parent_form: @
    new AntCat.SynonymsSection @element.find('.senior_synonyms_section'), parent_form: @

  initialize_references_section: =>
    new AntCat.ReferencesSection @element.find('.references_section'), parent_form: @

  initialize_parent_section: =>
    options = {}
    if @taxon_rank() == 'genus' or @taxon_rank() == 'tribe'
      options = {subfamilies_or_tribes_only: true}
    else if @taxon_rank() == 'species' or @taxon_rank() == 'subspecies'
      options = {genera_only: true}
    new AntCat.ParentSection options

  initialize_current_valid_name_section: =>
    new AntCat.CurrentValidNameSection()

  initialize_homonym_replaced_by_section: =>
    @homonym_replaced_by_name_row = $ 'tr#homonym_replaced_by_row'
    @status_selector = $ '#taxon_status'
    @status_selector.change => @hide_or_show_homonym_replaced_by()
    new AntCat.HomonymReplacedBySection $('#homonym_replaced_by_name_field'), parent_form: @
    @hide_or_show_homonym_replaced_by()

  initialize_current_valid_taxon_section: =>
    @current_valid_taxon_name_row = $ 'tr#current_valid_taxon_row'
    new AntCat.CurrentValidTaxonSection $('#current_valid_taxon_name_field'), parent_form: @

  initialize_task_buttons: =>
    @element.find('#add_taxon').click => @add_taxon(); false
    @element.find('#add_tribe').click => @add_tribe(); false
    @element.find('#elevate_to_species').click => @elevate_to_species(); false
    @element.find('#delete_taxon').click => @delete_taxon(); false
    @element.find('#convert_to_subspecies').click => @convert_to_subspecies(); false


  initialize_duplicate_handler: =>
    $(document).find('#new_taxon').submit => @popup_duplicate_window(); false



  initialize_events: =>
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER

  taxon_id: =>
    match = @form().attr('action').match /\d+/
    match and match[0]

  taxon_rank: =>
    $('#taxon_rank').val()

  hide_or_show_homonym_replaced_by: =>
    if @status_selector.val() == 'homonym'
      @homonym_replaced_by_name_row.show()
    else
      @homonym_replaced_by_name_row.hide()

  ###### overrides
  cancel: => window.location = $('#cancel_path').val()

  ###### client functions

  replace_junior_and_senior_synonyms_section: (content) =>
    $('.junior_and_senior_synonyms_section').replaceWith content
    @initialize_junior_and_senior_synonyms_section()

  elevate_to_species: =>
    return unless confirm 'Are you sure you want to elevate this subspecies to species?'
    $('#task_button_command').val('elevate_to_species')
    @submit()

  delete_taxon: =>
    return unless confirm 'Are you sure you want to delete this taxon?'
    return unless confirm "Note: It may take a few moments to check that this taxon isn't being referenced."
    $('#task_button_command').val('delete_taxon')
    @submit()

  convert_to_subspecies: =>
    window.location = $('#convert_to_subspecies_path').val()

  add_taxon: =>
    window.location = $('#add_taxon_path').val()

  add_tribe: =>
    window.location = $('#add_tribe_path').val()

  add_history_item_panel: ($panel) =>
    @element.find('.history_items').append $panel

  add_reference_panel: ($panel) =>
    @element.find('.reference_sections').append $panel

  on_form_open: =>
    @hide_duplicate_message()
    super

  duplicate_message_html: =>
    '<div id="dialog-duplicate" title="This new combination looks a lot like existing combinations."><p>
       <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
           Choose a representation:
           <div id="duplicate-radio">
    <input type="radio" id="radio1" name="radio"><label for="radio1">Choice 1</label>
    <input type="radio" id="radio2" name="radio" checked="checked"><label for="radio2">Choice 2</label>
    <input type="radio" id="radio3" name="radio"><label for="radio3">Choice 3</label>
  </div>
     </p></div>'

  popup_duplicate_window: =>
    event.preventDefault()
    # call back here to see if we need to do this. If so, store
    # the results of the callback
#    taxon_form = $('#new_taxon')
#    taxon_form.unbind("submit")
#    taxon_form.submit()




    @create_duplicate_message()


  get_radio_value: =>
    result = null
    $("#dialog-duplicate :radio").each ->
      if this.checked == true
        result = this.id
    result

  create_duplicate_message: =>
    @duplicate_message = $('#duplicate_message')
    @duplicate_message.append($(@duplicate_message_html()))
    dialog_box = $("#dialog-duplicate")
    dialog_box.dialog({
      resizable: true,
      height: 140,
      width: 520,
      modal: true,

      buttons: {
        "foo": (a) =>
          console.log "got a value:" + @get_radio_value()
        "Yes, create new combination": (a) =>
          window.location.href = '/taxa/new?parent_name_id=' + name_id +
            '&rank_to_create=' + @taxon_rank +
            '&previous_combination_id=' + taxon_id
        ,
        Cancel: () =>
          dialog_box.dialog("close")
      }
    })
    @show_duplicate_message()

  hide_duplicate_message: =>
    $('.duplicate_message').hide()


  show_duplicate_message: =>
    $('.duplicate_message').show()



