class AntCat.NameField extends AntCat.Panel
  constructor: ($parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    @taxon_rank = $parent_element.closest('form').find('#taxon_rank').val()
    @is_parent_name = ($parent_element.attr('id') == 'parent_name_field')
    super $parent_element.find('> .antcat_name_field'), @options
    @set_help()

  current_taxon_id: =>
    $('#current_taxon_id').val()

  species_id: =>
    $('#species_id').val()

  taxon_name_string: =>
    $('#taxon_name_string').val()

  current_reset_epithet: =>
    $('#reset_epithet').val()

  create_form: ($element, form_options) =>
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
    @hide_combination_message()
    super

  # This is the main entry point after submission. start
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
    $submit_button = @element.find('.controls .submit')
    $submit_button.text text

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    if (@taxon_rank == 'species' || @taxon_rank == 'subspecies') && @is_parent_name && parseInt($value_field.val()) != parseInt(value)
      @set_value_default(value)
    else
      @reset_value_id = $value_field.val()
      $value_field.val value

  set_value_default: (value) =>
    $value_field = $('#' + @value_id)
    @check_for_duplicates(value)

    # populates @duplicates variable
    if @duplicates == undefined
      @create_combination_message(value)
    else
      @create_duplicate_message(@duplicates, value)

    @reset_value_id = $value_field.val()
    $value_field.val value

  reset_autocomplete: =>
    $value_field = $('#' + @value_id)
    $value_field.val @reset_value_id
    $('.antcat_form .ui-autocomplete-input')[0].value = null
    $('#parent_name_field .display_button').text(@current_reset_epithet())

  combination_message_html: =>
    '<div id="dialog-confirm" title="Do you want a new combination?"><p>
       <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
       Would you like to create a new combination under this parent?
     </p></div>'

  create_combination_message: (name_id) =>
    action = @element.closest('form').attr('action')
    console.log('showing the message')
    @element.append($(@combination_message_html()))
    dialog_box = $("#dialog-confirm")
    dialog_box.dialog
      resizable: true
      height: 140
      width: 520
      modal: true
      buttons: @create_combination_message_buttons(name_id, dialog_box)

    @show_combination_message()

  create_combination_message_buttons: (name_id, dialog_box) =>
    button_hash = {}
    button_hash["Yes, create new combination"] = (a) =>
      window.location.href = '/taxa/redirect_by_parent_name_id?parent_name_id=' + name_id +
        '&rank_to_create=' + @taxon_rank +
        '&previous_combination_id=' + @current_taxon_id()

    button_hash["Cancel"] =
      id: "Cancel-Dialog"
      text: "Cancel"
      click: =>
        @reset_autocomplete()
        dialog_box.dialog("close")

    return button_hash

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
# Duplicates message handling
# -----------------------------------------
  duplicate_message_html: (data) =>
    message = '<div id="dialog-duplicate" title="This new combination looks a lot like existing combinations."><p>
       <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
           Choose a representation:
           <div id="duplicate-radio class="duplicate-radio">'

    generate_additional_homonym_option = true
    # one radio button per duplicate. If we hit a homonym case in here,
    # we don't need an additonal option for one.
    for i in [1..data.length] by 1
      j = i - 1
      item = data[j][Object.keys(data[0])[0]]
      message = message + @make_radio_html(item, j)

    if generate_additional_homonym_option
      message = @append_homonym_button(message, item)

    message = message + '</div></p></div>'
    message

  make_radio_html: (item, j) =>
    message = '<input type="radio" id='

    if item['duplicate_type'] == 'secondary_junior_homonym'
      message = message + 'secondary_junior_homonym'
      generate_additional_homonym_option = false
    else
      message = message + j

    if j == 0
      message = message + ' checked="checked" '
    message = message + ' name="radio">'
    message = message + '<label for="radio' +
      j +
      '">' +
      item.name_html_cache +
      ": " +
      item.author_citation

    if item['duplicate_type'] == 'secondary_junior_homonym'
      message = message + " This would become a secondary junior homonym; name conflict with distinct authorship"
    else
      message = message + " return to a previous usage"

    message = message + '</label>'
    message = message + '</br>'

    message

  append_homonym_button: (message, item) =>
    message = message + '<input type="radio" id="homonym' +
      '" name="radio"><label for="radio_homonym' +
      '">Create secondary junior homonym'

    # Covers only species here - how we deal with subspecies is TBD
    if item.name_html_cache != null
      message = message +
        ' of ' +
        item.name_html_cache +
        ": " +
        item.author_citation +
        '</label>'
    message

  get_radio_value: =>
    result = null
    $("#dialog-duplicate :radio").each ->
      if this.checked == true
        result = this.id
    result

  create_duplicate_message: (data, new_parent_name_id) =>
    @duplicate_message = $('#duplicate_message')
    @duplicate_message.append($(@duplicate_message_html(data)))
    dialog_box = $("#dialog-duplicate")
    dialog_box.dialog
      resizable: true
      height: 280
      width: 720
      modal: true
      buttons: @create_duplicate_message_buttons(data, new_parent_name_id, dialog_box)

    @show_duplicate_message()

  create_duplicate_message_buttons: (data, new_parent_name_id, dialog_box) =>
    button_hash = {}
    # TODO This code is nasty. there's gotta be a better way.
    button_hash["Yes, create new combination"] = (a) =>
      if (@get_radio_value() == 'homonym' || @get_radio_value() == 'secondary_junior_homonym')
        collision_resolution = 'homonym'
      else
        data_object = data[@get_radio_value()]
        if data_object['species'] != undefined
          collision_resolution = data_object['species'].id
        else if data_object['subspecies'] != undefined
          collision_resolution = data_object['subspecies'].id
      window.location.href = '/taxa/redirect_by_parent_name_id?parent_name_id=' + new_parent_name_id +
        '&rank_to_create=' + @taxon_rank +
        '&previous_combination_id=' + @current_taxon_id() +
        '&collision_resolution=' + collision_resolution

    button_hash["Cancel"] =
      id: "Cancel-Dialog"
      text: "Cancel"
      click: =>
        @reset_autocomplete()
        dialog_box.dialog("close")

    return button_hash

  # does synchronus ajax query
  # against the duplicates controller. The results appear in this.duplicates
  check_for_duplicates: (new_parent_name_id) =>
    url = "/taxa/find_duplicates?current_taxon_id=" +
        @current_taxon_id() +
        "&new_parent_name_id=" +
        new_parent_name_id +
        '&rank_to_create=' + @taxon_rank

    $.ajax
      url: url
      type: 'get'
      dataType: 'json'
      success: (data) =>
        @got_duplicate_data(data)
      async: false
      error: (xhr) => debugger

  # Hit from check_for_duplicates; if there are no duplicates, carry on.
  # Otherwise, popup dialog box via create_duplicate_message
  got_duplicate_data: (data) =>
    if data == null
      @duplicates = null
    else
      @duplicates = data

  hide_duplicate_message: =>
    $('.duplicate_message').hide()

  show_duplicate_message: =>
    $('.duplicate_message').show()

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
    url += '?species_only=1' if @options.species_only
    url += '?genera_only=1' if @options.genera_only
    url += '?subfamilies_or_tribes_only=1' if @options.subfamilies_or_tribes_only

    $textbox.autocomplete(autoFocus: true, source: url, minLength: 3)
      .data('uiAutocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
