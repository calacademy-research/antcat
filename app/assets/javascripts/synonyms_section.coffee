class AntCat.SynonymsSection
  constructor: (@element, @options = {}) ->
    AntCat.log 'SynonymsSection constructor: @element.size() != 1' unless @element.size() == 1
    @parent_form = @options.parent_form
    AntCat.log 'SynonymsSection constructor: !@parent_form' unless @parent_form
    @initialize()

  initialize: =>
    @setup_add_buttons()
    @setup_delete_buttons()

  setup_add_buttons: =>
    $add_button = @element.find 'button.add'
    AntCat.log 'SynonymsSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false

  setup_delete_buttons: =>
    $delete_buttons = @element.find 'button.delete'
    $delete_buttons.show() if AntCat.testing
    $delete_buttons.click (event) => @delete(event.target); false
    @element.find('.synonym_row').hover(
      (event) =>
        $(event.target).closest('.synonym_row')
          .select()
          .find('.delete').show().end()
      (event) =>
        AntCat.deselect()
        $delete_buttons.hide()
    )

  add: =>
    form = new AntCat.SynonymsSectionForm @element.find('.nested_form'), on_success: @handle_success
    form.open()

  handle_success: (data) =>
    @element.find('.synonyms_section').replaceWith data.content
    @initialize()

  delete: (target) =>
    return unless confirm 'Are you sure you want to delete this synonym?'
    taxon_id = $(target).data('taxon-id')
    synonym_id = $(target).data('synonym-id')
    url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}"
    $.post url, {_method: 'delete'}, null, 'json'
    $(target).closest('.synonym_row').remove()

  on_form_open: =>
    @options.parent_form.disable_buttons() if @options.parent_form

  on_form_close: =>
    @options.parent_form.enable_buttons() if @options.parent_form

class AntCat.SynonymsSectionForm extends AntCat.NestedForm
  constructor: ->
    super
    @textbox = @element.find('input[type=text]')
    AntCat.log 'SynonymsSectionForm initialize: no @textbox' unless @textbox.size() == 1
    @error_message = @element.find('#error_message')
    AntCat.log 'SynonymsSectionForm initialize: no @textbox' unless @textbox.size() == 1
    @setup_autocomplete()

  submit: =>
    return false if @textbox.val().length == 0
    @error_message.text ''
    super

  handle_application_error: (error_message) =>
    super
    @error_message.text error_message

  setup_autocomplete: =>
    return if AntCat.testing
    @textbox.autocomplete(
        autoFocus: true,
        source: "/name_pickers/search?taxa_only=true",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
