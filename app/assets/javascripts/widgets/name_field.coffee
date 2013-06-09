#%span#name_field
  #= render 'name_fields/panel', name_string: taxon.name.try(:name)
#new NameField $('#name_field'), value_id: <id-without-#>, parent_form: <form>,
# click_on_display,
# taxa_only, species_only, allow_blank, new_or_homonym, require_new

class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super $parent_element.find('> .antcat_name_field'), @options
    @element.find('.help').text @construct_help()

  create_form: ($element, form_options) =>
    form_options.taxa_only = @options.taxa_only
    form_options.species_only = @options.species_only
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

  construct_help: =>
    help = "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or clear this name." if @options.allow_blank
    help = "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or choose a homonym." if @options.new_or_homonym
    help = "Type a new taxon name" if @options.require_new
    help = "Click \"Add name\", or \"Cancel\"" if @deciding_whether_to_add_name
    help

  construct_parameters: =>
    action  = "?field=true"
    action += "&allow_blank=true" if @options.allow_blank
    action += "&require_existing=true" if @options.require_existing
    action += "&new_or_homonym=true" if @options.new_or_homonym
    action += "&require_new=true" if @options.require_new
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
      @deciding_whether_to_add_name = not @options.require_new

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
    @default_name_string = @options.default_name_string
    @setup_autocomplete @textbox
    super

  open: =>
    unless @textbox.val() or not @default_name_string
      @textbox.val @default_name_string
      @textbox.setCaretPos @default_name_string.length + 1
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
    url += '?species_only=1' if @options.species_only
    $textbox.autocomplete(autoFocus: true, source: url, minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
