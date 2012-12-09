class AntCat.TaxonPicker extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    @control = @element.find('input[type=text]')
    @setup_autocomplete @element.find('input[type=text]')
    @options.button_container = element.find('.buttons')
    @options.modal = true
    super

  setup_autocomplete: ($textbox) =>
    $textbox.autocomplete(
      autoFocus: true,
      source: "/taxon_pickers",
      minLength: 3,
      select: @select)
    .data( "autocomplete" )._renderItem = @render_item

  render_item: (ul, item) =>
    $("<li>")
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)

  select: (event, ui) =>
    # snaffle away the selected menu item's data
    @element.data 'taxt', ui.item.taxt

  open: =>
    @control.val ''
    super

  # returns the value of the taxon
  submit: (eventObject) =>
    @close()
    @options.on_ok @element.data('taxt')

  cancel: =>
    @close()
