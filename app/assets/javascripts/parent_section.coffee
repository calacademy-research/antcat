class AntCat.ParentSection
  constructor: (@element, @options) ->
    AntCat.log 'ParentNameSection constructor: @element.size() != 1' unless @element.size() == 1
    @parent_form = @options.parent_form; AntCat.log 'ParentNameSection constructor: !@parent_form' unless @parent_form
    @initialize()

  initialize: ->
    @homonym_replaced_by_name_row = $ 'tr#homonym_replaced_by'
    new AntCat.NameField $('#homonym_replaced_by_name_field'),
      value_id: 'taxon_homonym_replaced_by_name_attributes_id', parent_form: @parent_form, require_existing: true, taxa_only: true, allow_blank: true
    @parent_form.hide_or_show_homonym_replaced_by()
    @homonym_replaced_by_name_row.find('.help').text(
      'Type the name, or type characters in the name then choose a name from the drop-down list, or delete the name'
    )
