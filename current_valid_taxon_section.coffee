class AntCat.CurrentValidTaxonSection
  constructor: ->
    options = {value_id: 'taxon_current_valid_taxon_name_attributes_id'}
    new AntCat.NameField $('#current_valid_taxon_name_field'), options
