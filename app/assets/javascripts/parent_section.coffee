class AntCat.ParentSection
  constructor: (@element, @options) ->
    @parent_form = @options.parent_form
    new AntCat.NameField $('#parent_name_field'), value_id: 'taxon_parent_name_attributes_id', parent_form: @parent_form, species_only: true
