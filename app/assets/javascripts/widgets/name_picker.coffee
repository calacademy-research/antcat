class AntCat.NamePicker extends AntCat.Form

  constructor: (element, options = {}) ->
    @control = element.find('input[type=text]')
    @setup_autocomplete @control
    options.button_container = element.find('.buttons')
    options.field = false
    # should not be necessary to pass these arguments explicitly
    super element, options

  submit: =>
    return false if @control.val().length == 0
    @element.find('.error_messages').text('')
    super

  handle_application_error: (error_message) =>
    @element.find('.error_messages').text(error_message)

  setup_autocomplete: ($textbox) =>
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_pickers",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)
