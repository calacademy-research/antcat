class AntCat.TaxonPicker extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    @setup_autocomplete @element.find('input[type=text]')
    @options.button_container = element.find('.buttons')
    @options.modal = true
    super

  setup_autocomplete: ($textbox) =>
    $textbox.autocomplete(
      autoFocus: true,
      source: "/taxon_pickers",
      minLength: 3)
    .data( "autocomplete" )._renderItem = @render_item

  render_item: (ul, item) =>
    $( "<li>" )
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)

  # returns the value of the taxon
  submit: (eventObject) =>
    @close()
    @options.on_ok($(eventObject.currentTarget).attr('id'))

  cancel: =>
    @close()
