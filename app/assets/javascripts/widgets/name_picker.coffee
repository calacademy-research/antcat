class AntCat.NamePicker extends AntCat.Form

  constructor: (@parent_element, @options = {}) ->
    @options.field = true unless @options.field?
    @element = @parent_element.find('> .antcat_name_picker')
    @options.button_container = @element.find('.buttons')
    if @options.field
      @id = @element.find('.value').val()
      @taxon_id = @element.find('.taxon_id').val()
      displaying_or_editing = 'displaying'
    else
      @id = @options.id
      @taxon_id = @options.taxon_id
      displaying_or_editing = 'editing'
    @original_id = @id
    if @id
      @load '', displaying_or_editing
    else
      @initialize displaying_or_editing
    @

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

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .controls').disable()

  go_into_edit_mode: =>
    @edit.show()
    @display.hide()
    @textbox.focus()

  go_into_display_mode: =>
    @edit.hide()
    @display.show()

  submit: =>
    return false if @textbox.val().length == 0
    @element.find('.error_messages').text('')
    super
    false

  handle_success: (data) =>
    @id = data.id
    @element.find('.value').val(@id)
    #taxt = if @current_name() then @current_name().data 'taxt' else null
    super

  handle_application_error: (error_message) =>
    @element.find('.error_messages').text error_message

  cancel: =>
    @id = @original_id
    if @id
      @load '', 'displaying'
    else
      @initialize 'displaying'
    @element.find('.value').val(@id)
    super

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
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)
