class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options

  create_form: ($element, options) =>
    options.taxa_only = @options.taxa_only
    options.allow_blank = @options.allow_blank
    new AntCat.NameFieldForm $element, options

  before_submit: =>
    @show_error ''
    @set_add_name_field()

  on_form_success: (data) =>
    @set_value data.id
    @set_submit_button_text 'OK'
    @deciding_whether_to_add_name = false

  on_form_cancel: =>
    @show_error ''
    @set_submit_button_text 'OK'
    super unless @deciding_whether_to_add_name
    @deciding_whether_to_add_name = false

  on_application_error: (error_message) =>
    # an 'error' means that the name the user entered doesn't exist
    # we ask if they want to add it
    @set_submit_button_text 'Add this name'
    @show_error error_message
    @deciding_whether_to_add_name = true

  #------------
  set_add_name_field: =>
    $add_name_field = @element.find('#add_name')
    if @deciding_whether_to_add_name
      $add_name_field.val 'true'
    else
      $add_name_field.val ''

  set_submit_button_text: (text) =>
    $submit_button = @element.find('.buttons .submit span')
    $submit_button.text text

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    $value_field.val value

  show_error: (message) =>
    $error_messages = @element.find('.error_messages')
    $error_messages.text message

# -----------------------------------------
class AntCat.NameFieldForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    @options.button_container = '.buttons'
    @textbox = @element.find('input[type=text]')
    @setup_autocomplete @textbox
    super

  submit: =>
    return false if @textbox.val().length == 0 and not @options.allow_blank
    @options.before_submit() if @options.before_submit
    super
    false

  setup_autocomplete: ($textbox) =>
    return if AntCat.testing
    url = '/name_pickers/search'
    url += '?taxa_only=1' if @options.taxa_only
    $textbox.autocomplete(autoFocus: true, source: url, minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
