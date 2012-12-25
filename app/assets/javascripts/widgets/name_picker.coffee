class AntCat.NamePicker extends AntCat.Form

  constructor: (@parent_element, @options = {}) ->
    @options.field = true unless @options.field?
    @element = @parent_element.find('> .antcat_name_picker')
    @options.button_container = @element.find('.buttons')
    if @options.field
      @current_id = @element.find('.value').val()
      @current_taxon_id = @element.find('.taxon_id').val()
      displaying_or_editing = 'displaying'
    else
      @current_id = @options.id
      @current_taxon_id = @options.taxon_id
      displaying_or_editing = 'editing'
    @original_id = @current_id
    if @current_id
      @load '', displaying_or_editing
    else
      @initialize displaying_or_editing
    @

  load: (url = '', displaying_or_editing = 'editing') =>
    if url.indexOf('/name_picker') is -1
      url = '/name_picker?' + url
    url = url + '&' + $.param id: @current_id if @current_id
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
    @expansion = @element.find '> .expansion'
    @control = @element.find('.edit input[type=text]')

    @edit = @element.find('.edit')
    @display = @element.find('.display')

    @setup_autocomplete @control
    @initialize_buttons()
    @element.show()
    if displaying_or_editing == 'editing'
      @go_into_edit_mode()

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .expansion .controls').disable()

  editing: => @element.find('.edit:visible .nested_form').length > 0

  go_into_edit_mode: =>
    @edit.show()
    @display.hide()
    @control.focus()

  go_into_display_mode: =>
    @edit.hide()
    @display.hide()

  submit: =>
    return false if @control.val().length == 0
    @element.find('.error_messages').text('')
    super

  handle_success: (data) =>
    @element.find('.value').val(@current_id)
    #taxt = if @current_name() then @current_name().data 'taxt' else null
    # then send data back on_success(name_id, taxon_id, taxt)
    super

  handle_application_error: (error_message) =>
    @element.find('.error_messages').text error_message

  cancel: =>
    @current_id = @original_id
    if @current_id
      @load '', 'displaying'
    else
      @initialize 'displaying'
    @element.find('.value').val(@current_id)
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
