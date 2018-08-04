$ ->
  new AntCat.TaxonForm $('.taxon_form'), button_container: '.buttons_section'

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
    @initialize_events()
    super

  ###### initialization
  initialize_fields_section: =>
    name_field = new AntCat.NameField $('#name_field'), value_id: 'taxon_name_attributes_id', parent_form: @, new_or_homonym: true
    protonym_field = new AntCat.ProtonymField $('#protonym_name_field'), name_field, value_id: 'taxon_protonym_attributes_name_attributes_id', parent_form: @
    if $('#type_name_field').size() == 1
      new AntCat.TypeNameField $('#type_name_field'), protonym_field, value_id: 'taxon_type_name_attributes_id', parent_form: @, allow_blank: true

  initialize_parent_section: =>
    options = {}
    if @taxon_rank() == 'genus' or @taxon_rank() == 'tribe'
      options = {subfamilies_or_tribes_only: true}
    else if @taxon_rank() == 'species'
      options = {genera_only: true}
    else if @taxon_rank() == 'subspecies'
      options = {species_only: true}
    new AntCat.ParentSection options

  initialize_events: =>
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER

  taxon_rank: =>
    $('#taxon_rank').val()

  ###### client functions
  on_form_open: =>
    super
