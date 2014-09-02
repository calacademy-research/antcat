class AntCat.NameField extends AntCat.Panel

  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    @taxon_rank = $parent_element.closest('form').find('#taxon_rank').val()
    @is_parent_name = ($parent_element.attr('id') == 'parent_name_field')
    super $parent_element.find('> .antcat_name_field'), @options
    @set_help()

  create_form: ($element, form_options) =>
    form_options.taxa_only = @options.taxa_only
    form_options.subfamilies_or_tribes_only = @options.subfamilies_or_tribes_only
    form_options.genera_only = @options.genera_only
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

  set_help: =>
    text = if @deciding_whether_to_add_name
      "Click Add this name, or Cancel"
    else if @options.allow_blank
      "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or clear this name."
    else if @options.new_or_homonym
      "Type the name, or type characters in the name then choose a name from the drop-down list, or type a new name, or choose a homonym."
    else if @options.require_new
      "Type a new taxon name"
    else
      "Type the name, or type characters in the name then choose a name from the drop-down list."
    @element.find('.help').text text

  construct_parameters: =>
    action  = "?field=true"
    action += "&allow_blank=true" if @options.allow_blank
    action += "&require_existing=true" if @options.require_existing
    action += "&new_or_homonym=true" if @options.new_or_homonym
    action += "&require_new=true" if @options.require_new
    action += "&confirm_add_name=true" if @deciding_whether_to_add_name
    action

  on_form_open: =>
    @hide_combination_message()
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
    @show_combination_message()
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
    $submit_button = @element.find('.controls .submit span')
    $submit_button.text text

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    if (@taxon_rank == 'species' || @taxon_rank == 'subspecies') &&
       @is_parent_name && parseInt($value_field.val()) != parseInt(value)
      @create_combination_message(value)
    $value_field.val value

  combination_message_html: =>
    '<div id="dialog-confirm" title="Do you want a new combination?"><p>
       <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
       Would you like to create a new combination under this parent?
     </p></div>'

  create_combination_message: (name_id) =>
    action = @element.closest('form').attr('action')
    taxon_id = action.substr(action.lastIndexOf('/') + 1)
    console.log('showing the message')
    @element.append($(@combination_message_html()))
    dialog_box = $( "#dialog-confirm" )
    dialog_box.dialog({
      resizable: true,
      height: 140,
      width: 520,
      modal: true,
      buttons: {
        "Yes, create new combination": (a) =>
          window.location.href = '/taxa/new?parent_name_id=' + name_id +
                                 '&rank_to_create=' + @taxon_rank +
                                 '&previous_combination_id=' + taxon_id
        ,
        Cancel: () =>
          dialog_box.dialog( "close" )
      }
    })
    @show_combination_message()

  hide_combination_message: =>
    if message = @element.find('#combination_message')
      message.hide()

  show_combination_message: =>
    if message = @element.find('#combination_message')
      message.show()

  remove_combination_message: =>
    if message = @element.find('#combination_message')
      message.remove()

  show_error: (message) =>
    $error_messages = @element.find('.error_messages')
    $error_messages.text message

# -----------------------------------------
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
    return if AntCat.testing
    url = '/name_pickers/search'
    url += '?taxa_only=1' if @options.taxa_only
    url += '?species_only=1' if @options.species_only
    url += '?genera_only=1' if @options.genera_only
    url += '?subfamilies_or_tribes_only=1' if @options.subfamilies_or_tribes_only
    $textbox.autocomplete(autoFocus: true, source: url, minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
