class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options

  create_form: ($element, options) =>
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
    AntCat.log 'NameField before_submit: $add_name_field.size() != 1' unless $add_name_field.size() == 1
    if @deciding_whether_to_add_name
      $add_name_field.val 'true'
    else
      $add_name_field.val ''

  set_submit_button_text: (text) =>
    $submit_button = @element.find('.buttons .submit span')
    AntCat.log 'NameField on_application_error: $submit_button' unless $submit_button.size() == 1
    $submit_button.text text

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    AntCat.log 'NameField set_value: $value_field.size() != 1' unless $value_field.size() == 1
    $value_field.val value

  show_error: (message) =>
    $error_messages = @element.find('.error_messages')
    AntCat.log 'NameField show_error: $error_messages.size() != 1' unless $error_messages.size() == 1
    $error_messages.text message

# -----------------------------------------
class AntCat.NameFieldForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    @options.button_container = '.buttons'
    @textbox = @element.find('input[type=text]')
    AntCat.log 'NameFieldForm ctor: no @textbox' unless @textbox.size() == 1
    @setup_autocomplete @textbox
    super

  submit: =>
    return false if @textbox.val().length == 0
    @options.before_submit() if @options.before_submit
    super
    false

  setup_autocomplete: ($textbox) =>
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
