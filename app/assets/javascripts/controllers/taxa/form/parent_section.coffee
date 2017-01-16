class AntCat.ParentSection
  constructor: (options) ->
    options.value_id = 'taxon_parent_name_attributes_id'
    options.allow_blank = true
    options.require_existing = true
    new AntCat.NameField $('#parent_name_field'), options
