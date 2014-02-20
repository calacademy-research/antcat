class AntCat.ParentSection
  constructor: ->
    options = {value_id: 'taxon_parent_name_attributes_id', allow_blank: true, require_existing: true, taxa_only: true}
    new AntCat.NameField $('#parent_name_field'), options
