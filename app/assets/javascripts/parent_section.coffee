class AntCat.ParentSection
  constructor: (options) ->
    options.value_id = 'taxon_parent_name_attributes_id'
    options.allow_blank = true
    options.require_existing = true
    #options.check_for_duplicates = false
    new AntCat.NameField $('#parent_name_field'), options

#