class AntCat.ParentSection
  constructor: ->
    options = {value_id: 'taxon_parent_name_attributes_id'}
    new AntCat.NameField $('#parent_name_field'), options
