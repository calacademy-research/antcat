class AntCat.TaxonPicker extends AntCat.NestedForm

  constructor: (element, options = {}) ->
    @control = element.find('input[type=text]')
    @setup_autocomplete @control
    options.button_container = element.find('.buttons')
    options.modal = true
    # should not be necessary to pass these arguments explicitly
    super element, options

  setup_autocomplete: ($textbox) =>
    $textbox.autocomplete(
          autoFocus: true,
          source: "/taxon_pickers",
          minLength: 3,
          select: @select)
      .data('autocomplete')
      ._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)
