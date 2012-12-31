class AntCat.NamePicker extends AntCat.NestedForm

  constructor: (@parent_element, @options = {}) ->
    @options.field = true unless @options.field?
    @element = @parent_element.find('> .antcat_name_picker')
    @options.button_container = '.buttons'
    if @options.field
      @id = @element.find('.edit #id').val()
      displaying_or_editing = 'displaying'
    else
      @id = @options.id
      displaying_or_editing = 'editing'
    @original_id = @id
    if @id
      @load '', displaying_or_editing
    else
      @initialize displaying_or_editing
    @

  needs_to_initialize_buttons_in_constructor: => false

  form: =>
    AntCat.NestedForm.create_form_from @element.find '.nested_form'

  load: (url = '', displaying_or_editing = 'editing') =>
    if url.indexOf('/name_picker') is -1
      url = '/name_picker?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find '> .antcat_name_picker'
        @initialize displaying_or_editing
        @edit.find('#id').val(@id)
      error: (xhr) => debugger

  initialize: (displaying_or_editing = 'editing') =>
    @element.addClass 'modal' unless @options.field
    @edit = @element.find('.edit')
    @display = @element.find('.display')
    @textbox = @edit.find('input[type=text]')
    @setup_autocomplete @textbox
    @initialize_buttons()
    @element.show()
    if displaying_or_editing == 'editing'
      @go_into_edit_mode()
    else
      @go_into_display_mode()
    if @options.field
      # on/off is necessary to avoid triggering multiple times after Cancel
      @element.find('.display').off('click')
      @element.find('.display').on('click', @toggle_editing_and_display)
      @element.find('.expand_collapse_icon').off('click')
      @element.find('.expand_collapse_icon').on('click', @toggle_editing_and_display)

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .controls').disable()

  editing: => @edit.is ':visible'

  toggle_editing_and_display: =>
    if @editing()
      @go_into_display_mode()
    else
      @go_into_edit_mode()

  go_into_edit_mode: =>
    @edit.show()
    @display.hide()
    @textbox.focus()
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.expanded_image_path

  go_into_display_mode: =>
    @edit.hide()
    @display.show()
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.collapsed_image_path

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
    @element.find('.buttons [value="Add this name"]').val('OK')
    @id = data.id
    @edit.find('#id').val @id
    @edit.find('#name').val data.name
    @edit.find('#taxt').val data.taxt
    @edit.find('#taxon_id').val data.taxon_id
    @display.text data.name
    super

  handle_application_error: (error_message) =>
    @element.find('.buttons [value=OK]').val('Add this name')
    @element.find('.error_messages').text error_message
    @deciding_whether_to_add_name = true

  cancel: =>
    displaying_or_editing = 'displaying'
    if @deciding_whether_to_add_name
      @element.find('.buttons [value="Add this name"]').val('OK')
      displaying_or_editing = 'editing'
    @id = @original_id
    if @id
      @load '', displaying_or_editing
    else
      @initialize displaying_or_editing
    super unless @deciding_whether_to_add_name
    @deciding_whether_to_add_name = false
    false

  close: =>
    @go_into_display_mode() if @options.field
    super

  # -----------------------------------------
  setup_autocomplete: ($textbox) =>
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_pickers",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul
