class AntCat.CurrentValidTaxonSection
  constructor: (@element, @options) ->
    @parent_form = @options.parent_form
    @current_valid_taxon_name_row = $ 'tr#current_valid_taxon_row'
    new AntCat.NameField $('#current_valid_taxon_name_field'),
      value_id: 'taxon_current_valid_taxon_name_attributes_id', parent_form: @parent_form, require_existing: true, taxa_only: true, allow_blank: true
    @current_valid_taxon_name_row.find('.help').text(
      'Type the name, or type characters in the name then choose a name from the drop-down list, or delete the name'
    )
