class AntCat.NamePicker extends AntCat.Form

  constructor: (@parent_element, @options = {}) ->
    @options.field = true unless @options.field?
    @element = @parent_element.find('> .antcat_name_picker')
    @options.button_container = @element.find('.buttons')
    if @options.field
      @current_id = @element.find('.value').val()
      @current_taxon_id = @element.find('.taxon_id').val()
      expanded_or_collapsed = 'collapsed'
    else
      @current_id = @options.id
      @current_taxon_id = @options.taxon_id
      expanded_or_collapsed = 'expanded'
    @original_id = @current_id
    if @current_id
      @load '', expanded_or_collapsed
    else
      @initialize expanded_or_collapsed
    @

  load: (url = '', expanded_or_collapsed = 'expanded') =>
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
        @initialize expanded_or_collapsed
      error: (xhr) => debugger

  initialize: (expanded_or_collapsed = 'expanded') =>
    @element.addClass 'modal' unless @options.field
    @expansion = @element.find '> .expansion'
    @control = @element.find('.edit input[type=text]')

    @edit = @element.find('.edit')
    @display = @element.find('.display')

    @setup_autocomplete @control
    @initialize_buttons()
    @element.show()
    if expanded_or_collapsed == 'expanded'
      @go_into_edit_mode()

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .expansion .controls').disable()

  editing: => @element.find('.edit:visible .nested_form').length > 0

  go_into_edit_mode: =>
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.expanded_image_path
    @edit.show()
    @display.hide()
    @control.focus()

  go_into_display_mode: =>
    @edit.hide()
    @display.hide()
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.collapsed_image_path

  submit: =>
    return false if @control.val().length == 0
    @element.find('.error_messages').text('')
    super

  handle_success: =>
    @element.find('.value').val(@current_id)
    #taxt = if @current_name() then @current_name().data 'taxt' else null
    # then send data back on_success(name_id, taxon_id, taxt)
    super

  handle_application_error: (error_message) =>
    @element.find('.error_messages').text error_message

  cancel: =>
    @current_id = @original_id
    @element.find('.value').val(@current_id)
    @load('', 'collapsed')
    @options.on_cancel if @options.on_cancel
    @close()

  close: =>
    if @options.field
      @hide_expansion()
    else
      @element.slideUp 'fast', =>
    @options.on_close if @options.on_close

  enable_controls: => @expansion.find('.controls').undisable()
  disable_controls: => @expansion.find('.controls').disable()

  # -----------------------------------------
  update_help: =>
    any_search_results = @search_results.find('.name').length > 0
    if @current_name()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
        help = if @options.field then "Use" else "Click OK to use"
      help += " this name, or add or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a name to use"
      else
        help = "Find a name to use"
      help += ', or add one'
    @element.find('.help_banner_text').text help

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
