class AntCat.SynonymsSection
  constructor: ($element) ->
    @element = $element.parent()
    AntCat.log 'SynonymsSection constructor: @element.size() != 1' unless @element.size() == 1
    @form = new AntCat.SynonymsSectionForm @element.find('.nested_form')

class AntCat.SynonymsSectionForm extends AntCat.NestedForm
  constructor: ->
    super
    @textbox = @element.find('input[type=text]')
    AntCat.log 'SynonymsSectionForm initialize: no @textbox' unless @textbox.size() == 1
    @setup_autocomplete @textbox

  submit: =>
    #return false if @textbox.val().length == 0
    @element.find('.error_messages').text('')
    super

  setup_autocomplete: ($textbox) =>
    AntCat.log 'SynonymsSection setup_autocomplete: no $textbox' unless $textbox.size() == 1
    return if AntCat.testing
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_popups/search",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
