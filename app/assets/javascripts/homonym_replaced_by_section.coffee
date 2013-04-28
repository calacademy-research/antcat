class AntCat.HomonymReplacedBySection
  constructor: (@element, @options = {}) ->
    AntCat.log 'HomonymReplacedByNameSection constructor: @element.size() != 1' unless @element.size() == 1
    @parent_form = @options.parent_form; AntCat.log 'HomonymReplacedByNameSection constructor: !@parent_form' unless @parent_form
    @initialize()

  initialize: (@element, @options = {}) ->
    @homonym_replaced_by_name_column = $ 'tr#homonym_replaced_by'
    new AntCat.NameField $('#homonym_replaced_by_name_field'),
      value_id: 'taxon_homonym_replaced_by_name_attributes_id', parent_form: @parent_form, taxa_only: true, allow_blank: true
    @parent_form.hide_or_show_homonym_replaced_by()
    @homonym_replaced_by_name_column.find('.help').text(
      'Type the name, or type characters in the name then choose a name from the drop-down list, or delete the name'
    )
