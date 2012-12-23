class AntCat.ReferencePicker

  constructor: (@parent_element, @options = {}) ->
    @element = @parent_element.find('> .antcat_reference_picker')
    if @options.modal
      @current_reference_id = @options.id
    else
      @current_reference_id = @element.find('.value').val()
    @original_reference_id = @current_reference_id
    expanded_or_collapsed = @options.modal ? 'expanded' : 'collapsed'
    if @current_reference_id
      @load('', expanded_or_collapsed)
    else
      @initialize(expanded_or_collapsed)
    @

  load: (url = '', expanded_or_collapsed = 'expanded') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @current_reference_id if @current_reference_id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find('> .antcat_reference_picker')
        @initialize(expanded_or_collapsed)
      error: (xhr) => debugger

  initialize: (expanded_or_collapsed = 'expanded') =>
    @element.addClass 'modal' if @options.modal
    @template = @element.find '> .template'
    @current = @element.find '> .current'
    @control_form = @find_control_form()
    @search_selector = @control_form.find '.search_selector'
    @textbox = @control_form.find '.q'
    @search_results = @element.find '> .expansion > .search_results'
    @expansion = @element.find '> .expansion'

    @current.click => @toggle_expansion() unless @options.modal or @editing()

    @setup_control_form()
    @setup_references()
    @handle_new_selection()

    @element.show()
    if expanded_or_collapsed == 'expanded'
      @show_expansion()
      @textbox.focus()

  start_throbbing: =>
    @element.find('.throbber img').show()
    @find_control_form().find('.controls').disable()

  find_control_form: => @element.find '> .expansion > .control_form'

  editing: => @element.find('.edit:visible .nested_form').length > 0

  show_expansion: =>
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.expanded_image_path
    @expansion.show()
    # apparently, can't setup selectmenu unless it's visible
    @setup_search_selector()
    @textbox.focus()

  hide_expansion: =>
    @expansion.hide()
    @element.find('.expand_collapse_icon img').attr 'src', AntCat.collapsed_image_path
  toggle_expansion: => if @expansion.is ':hidden' then @show_expansion() else @hide_expansion()

  search: =>
    @load @get_search_parameters()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @get_search_parameters()

  get_search_parameters: =>
    $.param q: @textbox.val(), search_selector: @search_selector.val()

  close: (cancel = false) =>
    taxt = if not cancel and @current_reference() then @current_reference().data 'taxt' else null
    if @options.modal
      @element.slideUp 'fast', =>
    @options.on_done taxt if @options.on_done

  cancel: =>
    @current_reference_id = @original_reference_id
    @load('', 'collapsed')
    @hide_expansion()
    @close true

  setup_control_form: =>
    self = @
    @control_form
      .find('.controls')
        .undisable()
        .find(':button')
          .unbutton()
          .button()
          .end()
        .end()

      .find(':button.ok')
        .click =>
          @element.find('.value').val @current_reference_id
          if @options.modal
            @close()
          else
            @hide_expansion()
          false
        .end()

      .find(':button.close')
        .click =>
          @cancel()
          false
        .end()

      .find(':button.add')
        .click =>
          @add_reference()
          false
        .end()

      .find(':button.go')
        .click =>
          @search()
          false
        .end()

      .find('.q')
        .keypress (event) =>
          return true unless event.which is $.ui.keyCode.ENTER
          @search()
          false
        .end()

      .find('.pagination a')
        .click ->
          self.load_clicked_page @
          false
        .end()

    @setup_search_selector()
    @enable_search_author_autocomplete()

  setup_search_selector: =>
    @search_selector
      .selectmenu('destroy')
      .selectmenu(wrapperElement: "<span />")
      .change =>
        new_type = @search_selector.find('option:selected').text()
        if new_type is 'Search for'
          @disable_search_author_autocomplete()
        else
          @enable_search_author_autocomplete()
        @textbox.focus()

  enable_controls: => @control_form.find('.controls').undisable()
  disable_controls: => @control_form.find('.controls').disable()

  # -----------------------------------------
  add_reference: =>
    @make_current @template.find('.reference'), true

  setup_references: =>
    @element
      .find('.reference').reference_panel(
          on_form_open: @on_reference_form_open
          on_form_close: @on_reference_form_close
          on_form_done: @on_reference_form_done)
        .end()

    @search_results
      .find(".reference .item_#{@current_reference_id} div.display")
        .addClass('ui-selected')
        .end()

    @element.find('div.display').bind 'click', @handle_click
    @element.find('div.display').hover(@hover, @unhover)

  hover: (event) =>
    @search_results.find('.display').removeClass('ui-selecting')
    $target = $(event.target)
    $target = $target.closest('.display') unless $target.hasClass('display')
    $target.addClass('ui-selecting')
  unhover: (event) =>
    $(event.target).removeClass('ui-selecting')

  handle_click: (event) =>
    @element.find('div.display').removeClass('ui-selected').removeClass('ui-selecting')
    $(event.target).addClass('ui-selected')
    @handle_new_selection()

  on_reference_form_open: => @disable_controls()
  on_reference_form_close: => @enable_controls()
  on_reference_form_done: ($panel) =>
    id = $panel.data 'id'
    $(".item_#{id}").each -> $(@).replaceWith $panel.clone()
    @setup_references()

  # 'current' is the reference panel at the top of the picker, above the controls
  make_current: ($panel, edit = false) =>
    $current_contents = @current.find '> tbody > tr > td'
    $new_contents = $panel.clone()
    $current_contents.html $new_contents
    $new_current_reference = @current.find('.reference')
    $new_current_reference
      .find('div.display').removeClass('ui-selected ui-selectee').end()
      .reference_panel(
          on_form_open: @on_reference_form_open
          on_form_close: @on_reference_form_close
          on_form_done: @on_reference_form_done
          edit: edit)
    @element.removeClass 'has_no_current_reference'

  handle_new_selection: =>
    $selected_reference = @selected_reference()
    @make_current $selected_reference if $selected_reference

    @current_reference_id = if @current_reference() then @current_reference().data 'id' else null
    @element.toggleClass 'has_no_current_reference', not @current_reference()
    @update_help_banner()
    @options.on_change(@value()) if @options.on_change

  value: =>
    @current_reference_id

  selected_reference: =>
    results = @search_results.find 'div.display.ui-selected'
    return if results.length is 0
    results.closest '.reference'

  current_reference: =>
    references = @current.find('.reference')
    return if references.length is 0
    return unless references.data 'id'
    references

  # -----------------------------------------
  enable_search_author_autocomplete: =>
    return if AntCat.testing
    @enable_browser_autocomplete false
    @textbox.autocomplete
      autoFocus: true
      minLength: 3
      source: (request, result_handler) ->
        search_term = AntCat.ReferencePicker.extract_author_search_term(@element.val(), $(@element).getSelection().start)
        if search_term.length >= 3
          $.getJSON "/authors/all", term: search_term, result_handler
        else
          result_handler []
    # don't update the search textbox when the autocomplete item changes
    focus: -> false
    select: (event, data) ->
      value_and_position = AntCat.ReferencePicker.insert_author(@element.val(), @element.getSelection().start, data.item.value)
      @element.val value_and_position.string
      @element.setCaretPos value_and_position.position + 1
      false

  disable_search_author_autocomplete: =>
    @textbox.autocomplete 'destroy'
    @enable_browser_autocomplete true

  enable_browser_autocomplete: (on_or_off) =>
    @element.closest('form').attr 'autocomplete', if on_or_off then '' else 'off'

  @extract_author_search_term: (string, position) =>
    return ""  if string.length is 0
    before_cursor = string.substring 0, position
    prior_semicolon = before_cursor.lastIndexOf ";"
    $.trim before_cursor.substring prior_semicolon + 1, position

  @insert_author: (string, position, author) ->
    if string.length is 0
      return {string: string, position: 0}
    before_cursor = string.substring 0, position
    prior_semicolon = before_cursor.lastIndexOf ";"

    before_prior_semicolon = string.substring 0, prior_semicolon
    before_prior_semicolon += "; "  if before_prior_semicolon.length > 0

    after_cursor = string.substring position, string.length

    string = before_prior_semicolon + author + "; " + $.trim after_cursor

    after_cursor = string.substring position, string.length
    next_semicolon = after_cursor.indexOf ";"
    position = next_semicolon + position + 2

    {string: string, position: position}

  # -----------------------------------------
  update_help_banner: =>
    any_search_results = @search_results.find('.reference').length > 0
    if @current_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = if @options.modal then "Click OK to use" else "Use"
      help += " this reference, or add or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to use"
      else
        help = "Find a reference to use"
      help += ', or add one'
    @set_help_banner help

  set_help_banner: (text) =>
    @element.find('.help_banner_text').text text

