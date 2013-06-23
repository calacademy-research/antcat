class AntCat.HomonymReplacedBySection
  constructor: (@element, @options) ->
    @parent_form = @options.parent_form
    @initialize()

  initialize: ->
    @homonym_replaced_by_name_row = $ 'tr#homonym_replaced_by'
    new AntCat.NameField $('#homonym_replaced_by_name_field'),
      value_id: 'taxon_homonym_replaced_by_name_attributes_id', parent_form: @parent_form, require_existing: true, taxa_only: true, allow_blank: true
    @parent_form.hide_or_show_homonym_replaced_by()
    @homonym_replaced_by_name_row.find('.help').text(
      'Type the name, or type characters in the name then choose a name from the drop-down list, or delete the name'
    )
