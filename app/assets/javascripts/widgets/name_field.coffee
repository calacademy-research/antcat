#%span#name_field
  #= render 'name_fields/panel', name_string: taxon.name.try(:name)
#new NameField $('#name_field'), value_id: <id-without-#>, parent_form: <form>,
# click_on_display,
# taxa_only, allow_blank, new_or_homonym

class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options
    @element.find('.help').text @construct_help()

  create_form: ($element, options) =>
    options.taxa_only = @options.taxa_only
    options.allow_blank = @options.allow_blank
    new AntCat.NameFieldForm $element, options

  before_submit: =>
    @form().add_to_url @construct_parameters()
    @show_error ''
    @set_add_name_field()

  construct_help: =>
    help = "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name"
    help = "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or clear this name" if @options.allow_blank
    help = "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or choose a homonym" if @options.new_or_homonym
    help = "Click \"Add name\", or \"Cancel\"" if @deciding_whether_to_add_name
    help

  construct_parameters: =>
    action  = "?field=true"
    action += "&allow_blank=true" if @options.allow_blank
    action += "&require_existing=true" if @options.require_existing
    action += "&new_or_homonym=true" if @options.new_or_homonym
    action += "&confirm_add_name=true" if @deciding_whether_to_add_name
    action

  on_form_success: (data) =>
    @set_value data.id
    @set_submit_button_text 'OK'
    @deciding_whether_to_add_name = false

  on_form_cancel: =>
    @show_error ''
    @set_submit_button_text 'OK'
    super
    @deciding_whether_to_add_name = false

  on_application_error: (data) =>
    @show_error data.error_message
    if data.reason == 'not found' and @options.require_existing
      @deciding_whether_to_add_name = false
    else
      @set_submit_button_text data.submit_button_text
      @deciding_whether_to_add_name = true

  #------------
  set_add_name_field: =>
    $confirm_add_name_field = @element.find('#confirm_add_name')
    if @deciding_whether_to_add_name
      $confirm_add_name_field.val 'true'
    else
      $confirm_add_name_field.val ''

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

  add_to_url: (parameters) =>
    @element.data 'action', @element.data('action') + parameters

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
