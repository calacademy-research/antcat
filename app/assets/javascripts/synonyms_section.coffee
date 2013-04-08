class AntCat.SynonymsSection
  constructor: (@element) ->
    AntCat.log 'SynonymsSection constructor: @element.size() != 1' unless @element.size() == 1
    @initialize()

  initialize: =>
    @form = new AntCat.SynonymsSectionForm @element.find('.nested_form'), on_success: @handle_success
    $add_button = @element.find 'button.add'
    AntCat.log 'SynonymsSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false
    @element.find('button.delete').show() if AntCat.testing
    $delete_buttons = @element.find 'button.delete'
    AntCat.log 'SynonymsSection initialize: $delete_buttons.size() < 1' unless $delete_buttons.size() >= 1
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
    @form.open()

  delete: (target) =>
    return unless confirm 'Are you sure you want to delete this synonym?'
    taxon_id = $(target).data('taxon-id')
    synonym_id = $(target).data('synonym-id')
    url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}"
    $.post url, {_method: 'delete'}, null, 'json'
    $(target).closest('.synonym_row').remove()

class AntCat.SynonymsSectionForm extends AntCat.NestedForm
  constructor: ->
    super
    @textbox = @element.find('input[type=text]')
    AntCat.log 'SynonymsSectionForm initialize: no @textbox' unless @textbox.size() == 1
    @setup_autocomplete @textbox

  submit: =>
    return false if @textbox.val().length == 0
    @element.find('#error_message').text('')
    super

  handle_application_error: (error_message) =>
    @element.find('#error_message').text error_message

  setup_autocomplete: ($textbox) =>
    AntCat.log 'SynonymsSection setup_autocomplete: no $textbox' unless $textbox.size() == 1
    return if AntCat.testing
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_pickers/search",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
