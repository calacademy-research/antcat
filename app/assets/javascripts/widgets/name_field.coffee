class AntCat.NameField extends AntCat.Panel
  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options
    @set_help()

  create_form: ($element, form_options) =>
    form_options.allow_blank = @options.allow_blank
    form_options.default_name_string = @get_default_name_string()
    new AntCat.NameFieldForm $element, form_options

  get_default_name_string: =>
    default_name_string_field = @element.find '#default_name_string'
    default_name_string_field.val()

  before_submit: =>
    @form().add_to_url @construct_parameters()
    @show_error ''
    @set_add_name_field()

  set_help: =>
    text =
      if @deciding_whether_to_add_name
        "Click Add this name, or Cancel"
      else if @options.allow_blank
        "Type the name, or type characters in the name then choose a name
        from the drop-down list, or type a new name, or clear this name."
      else if @options.new_or_homonym
        "Type the name, or type characters in the name then choose a name
        from the drop-down list, or type a new name, or choose a homonym."
      else if @options.require_new
        "Type a new taxon name"
      else
        "Type the name, or type characters in the name then choose a name
        from the drop-down list."

    @element.find('.help').text text

  construct_parameters: =>
    action = "?field=true"
    action += "&allow_blank=true" if @options.allow_blank
    action += "&require_existing=true" if @options.require_existing
    action += "&new_or_homonym=true" if @options.new_or_homonym
    action += "&require_new=true" if @options.require_new
    action += "&confirm_add_name=true" if @deciding_whether_to_add_name
    action

  on_form_open: =>
    super

  on_form_success: (data) =>
    @set_value data.id
    @set_submit_button_text 'OK'
    @deciding_whether_to_add_name = false
    @set_help()

  on_form_cancel: =>
    @show_error ''
    @set_submit_button_text 'OK'
    super
    @deciding_whether_to_add_name = false
    @set_help()

  on_application_error: (data) =>
    @show_error data.error_message
    if data.reason == 'not found' and @options.require_existing
      @deciding_whether_to_add_name = false
    else
      @set_submit_button_text data.submit_button_text
      @deciding_whether_to_add_name = not @options.require_new
    @set_help()

  #------------

  set_add_name_field: =>
    $confirm_add_name_field = @element.find('#confirm_add_name')
    if @deciding_whether_to_add_name
      $confirm_add_name_field.val 'true'
    else
      $confirm_add_name_field.val ''

  set_submit_button_text: (text) =>
    $submit_button = @element.find('.controls .submit')
    $submit_button.text text

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    @reset_value_id = $value_field.val()
    $value_field.val value

  show_error: (message) =>
    $error_messages = @element.find('.error_messages')
    $error_messages.text message

class AntCat.NameFieldForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    @options.button_container = '.controls'
    @textbox = @element.find('input[type=text]')
    @default_name_string = @options.default_name_string
    @setup_autocomplete @textbox
    super

  open: =>
    @default_name()
    super

  default_name: =>
    unless @textbox.val() or not @default_name_string
      @textbox.val @default_name_string
      @textbox.setCaretPos @default_name_string.length + 1

  add_to_url: (parameters) =>
    @element.data 'action', @element.data('action') + parameters

  submit: =>
    return false if @textbox.val().length == 0 and not @options.allow_blank
    @options.before_submit() if @options.before_submit
    super
    false

  setup_autocomplete: ($textbox) =>
    url = '/name_pickers/search'

    $textbox.autocomplete(autoFocus: true, source: url, minLength: 3)
      .data('uiAutocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
