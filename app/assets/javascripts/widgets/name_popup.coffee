class AntCat.NamePopup extends AntCat.NestedForm

  constructor: (@parent_element, @options = {}) ->
    @options.field = false

    @element = @parent_element.find '> .antcat_name_popup'
    AntCat.check 'NamePopup', '@element', @element

    @id = @options.id
    @type = @options.type

    if @id
      @load()
    else
      @initialize()
      @textbox.val(@options.initial_value) if @options.initial_value
    @

  load: =>
    @start_throbbing()
    $.ajax
      url: "/name_popups/#{@type}/#{@id}"
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find '> .antcat_name_popup'
        @initialize()
      error: (xhr) => debugger

  initialize: =>
    @element.addClass 'antcat_form'
    @options.button_container = '.controls'
    @textbox = @element.find('input[type=text]')
    AntCat.check 'NamePopup.initialize', '@textbox', @textbox

    @setup_autocomplete @textbox
    @initialize_buttons()

    @element.show()
    @focus_initial_control()

  initial_control_to_focus: =>
    @textbox

  form: =>
    AntCat.NestedForm.create_form_from @element.find '.nested_form'

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .controls').disable()

  submit: =>
    return false if @textbox.val().length == 0
    @element.find('.error_messages').text('')
    super
    false

  before_submit: (form, options) =>
    # form is an array of name-value pairs (from jQuery Form)
    alert '4th element is not add_name' unless form[4].name == 'add_name'
    if @deciding_whether_to_add_name
      form[4].value = 'true'
    else
      form[4].value = ''
    true

  handle_success: (data) =>
    @element.find('.controls .submit').val('OK')
    @id = data.id
    @element.find('#id').val @id
    @element.find('#name').val data.name
    @element.find('#taxt').val data.taxt
    @element.find('#taxon_id').val data.taxon_id
    super

  handle_application_error: (data) =>
    # an error means that the name the user entered doesn't exist
    # we ask if they want to add it
    submit_button = @element.find('.controls .submit span')
    AntCat.check 'NamePopup.handle_application_error', '@submit_button', @submit_button
    submit_button.text('Add this name')
    @element.find('.error_messages').text data.error_message
    @deciding_whether_to_add_name = true

  cancel: =>
    @element.find('.error_messages').text ''
    if @deciding_whether_to_add_name
      @element.find('.controls .submit').val('OK')
    super unless @deciding_whether_to_add_name
    @deciding_whether_to_add_name = false
    false

  # -----------------------------------------
  setup_autocomplete: ($textbox) =>
    AntCat.check 'NamePopup.setup_autocomplete', '@textbox', @textbox
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
