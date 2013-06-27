class AntCat.ParentSection
  constructor: ->
    rank_selector = $('#parent_rank_selector').val()
    options = {value_id: 'taxon_parent_name_attributes_id'}
    options[rank_selector] = true
    new AntCat.NameField $('#parent_name_field'), options
