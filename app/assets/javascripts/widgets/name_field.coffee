class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options

  create_form: ($element, options) =>
    options.button_container = @options.parent_buttons
    new AntCat.NameFieldForm $element, options

  form: =>
    @_form or= @create_form @element.find('.nested_form'),
      on_close:             @on_form_close
      on_response:          @on_form_response
      on_success:           @on_form_success
      on_cancel:            @on_form_cancel
      on_application_error: @on_application_error
      before_submit:        @before_submit

  before_submit: =>
    return false if @textbox.val().length == 0
    @element.find('.error_messages').text('')
    $add_name_field = @element.find('#add_name')
    AntCat.log 'NameField before_submit: $add_name_field.size() != 1' unless $add_name_field.size() == 1
    if @deciding_whether_to_add_name
      $add_name_field.val 'true'
    else
      $add_name_field.val ''

  initialize: =>
    super
    @element.addClass 'antcat_name_field'
    @textbox = @element.find('input[type=text]')
    AntCat.log 'NameField initialize: no @textbox' unless @textbox.size() == 1

    @setup_autocomplete @textbox
    #@initialize_buttons()

    #@element.show()
    #@textbox.focus()

  on_form_success: (data) =>
    @element.find('.buttons .submit').val('OK')
    $value_field = $('#' + @value_id)
    AntCat.log 'NameField on_form_success: $value_field.size() != 1' unless $value_field.size() == 1
    $value_field.val data.id
    @deciding_whether_to_add_name = false

  on_application_error: (error_message) =>
    # an 'error' means that the name the user entered doesn't exist
    # we ask if they want to add it
    $submit_button = @element.find('.buttons .submit span')
    AntCat.log 'NameField on_application_error: $submit_button' unless $submit_button.size() == 1
    $submit_button.text 'Add this name'
    @element.find('.error_messages').text error_message
    @deciding_whether_to_add_name = true

  on_form_cancel: =>
    @element.find('.error_messages').text ''
    if @deciding_whether_to_add_name
      @element.find('.buttons .submit').val('OK')
    super unless @deciding_whether_to_add_name
    @deciding_whether_to_add_name = false

  # -----------------------------------------
  setup_autocomplete: ($textbox) =>
    AntCat.log 'NameField setup_autocomplete: no $textbox' unless $textbox.size() == 1
    return if AntCat.testing
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_fields/search",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul

# -----------------------------------------
class AntCat.NameFieldForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    @options.button_container = '.buttons'
    super

  submit: =>
    @options.before_submit() if @options.before_submit
    super
    false
