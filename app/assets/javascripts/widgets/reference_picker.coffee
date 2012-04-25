class AntCat.ReferencePicker

  constructor: (parent, @original_reference_id, @result_handler) ->
    @current_reference_id = @original_reference_id
    @create parent
    @load()
    @

  create: (parent) =>
    @element = $('<div/>').addClass 'antcat_reference_picker ui-widget ui-widget-content ui-corner-all'
    @element.append @bootstrap_help_banner()
    @element.appendTo parent

  bootstrap_help_banner: =>
    $ """
    <form class='search_form'>
      <table><tr><td/><td>
        <div class='ok_cancel_controls'/>
        <div class='search_controls'/>
        <div class='help_banner'><span class='help_banner_text'/></div>
      </td></tr></table>
      <div class='throbber'/>
    </form>
    """

  load: (url = '') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @current_reference_id if @current_reference_id

    $throbber_image = @element.find('.throbber img')
    if $throbber_image.length > 0
      @element.find('.help_banner_text').html('')
      $throbber_image.show()
    else
      @element.find('.help_banner_text').html 'Loading&hellip;'
    @element.find('.search_form .controls').disable()

    # debug code to leave throbber up for a little while
    setTimeout(=> $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.html data
        @initialize()
      error: (xhr) => debugger
    0)

  initialize: =>
    @search_selector = @element.find '.search_selector'
    @textbox = @element.find '.q'

    @setup_search()
    @setup_references()
    @handle_new_selection()
    @textbox.focus()

  search: =>
    @load $.param q: @textbox.val(), search_selector: @search_selector.val()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @element.find('> .search_form').serialize()

  close: (cancel = false) =>
    taxt = if not cancel and @current_reference() then @current_reference().data 'taxt' else null
    @element.slideUp 'fast', =>
      @element.remove()
      @result_handler taxt if @result_handler

  cancel: =>
    @close true

  setup_search: =>
    self = @
    @element.find('.search_form')
      .submit =>
        @search()
        false
      .keypress (event) =>
        return true unless event.which is $.ui.keyCode.ENTER
        @search()
        false
      .find('.controls')
        .removeClass('ui-state-disabled')
      .find(':button, :submit')
        .button()
        .end()
      .find(':button.ok')
        .click =>
          @close()
          false
        .end()
      .find(':button.add')
        .click =>
          @add()
          false
        .end()
      .find(':button.close')
        .click =>
          @cancel()
          false
        .end()
      .find('.pagination a')
        .click ->
          self.load_clicked_page this
          false
        .end()

    @setup_search_selector()
    @enable_search_author_autocomplete()

  setup_search_selector: =>
    @search_selector
      .selectmenu(wrapperElement: "<span />")
      .change =>
        new_type = @search_selector.find('option:selected').text()
        if new_type is 'Search for'
          @disable_search_author_autocomplete()
        else
          @enable_search_author_autocomplete()
        @textbox.focus()

  setup_references: =>
    self = @
    @element
      .find('.reference').reference_panel(
          on_form_open: @on_reference_form_open
          on_form_close: @on_reference_form_close
          on_form_done: @on_reference_form_done
          on_form_cancel: @on_reference_form_cancel)
        .end()
      .find(".search_results .reference_#{@current_reference_id} div.display")
        .addClass('ui-selected')
        .end()
      .find('.search_results')
        .selectable('destroy')
        .selectable(filter: 'div.display', stop: @handle_new_selection, cancel: '.icons, div.edit')
        .end()

  on_reference_form_open: =>
    @element.find('.search_form .controls').disable()

  on_reference_form_close: =>
    @element.find('.search_form .controls').removeClass 'ui-state-disabled'

  on_reference_form_done: (reference_selector) =>
    @setup_references()
    @element
      .find(reference_selector)
        .effect("highlight", {color: 'darkgreen'}, 3000)
        .end()
      .find('.search_form .controls')
        .removeClass('ui-state-disabled')
        .end()
    @element.find('.icon.edit').show() if AntCat.testing

  handle_new_selection: =>
    selected_reference = @selected_reference()
    if selected_reference
      @element
        .find('.current_reference td')
          .html(selected_reference.clone(true).removeClass 'ui-selected ui-selectee')
    @current_reference_id = if @current_reference() then @current_reference().data 'id' else null
    @element.toggleClass 'has-no-current-reference', not @current_reference()
    @update_help_banner()

  selected_reference: =>
    results = @element.find '.search_results div.display.ui-selected'
    return if results.length is 0
    results.closest '.reference'

  current_reference: =>
    references = @element.find('.current_reference .reference')
    return if references.length is 0
    references

  # -----------------------------------------
  enable_search_author_autocomplete: =>
    @search_selector.closest('form').attr 'autocomplete', 'off'
    return if AntCat.testing
    self = @
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
    @search_selector.closest('form').removeAttr 'autocomplete'

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
    verb = if @original_reference_id then 'use' else 'insert'
    any_search_results = @element.find('.search_results .reference').length > 0
    if @current_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = "Click OK to #{verb} this reference, or add or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to #{verb}"
      else
        help = "Find a reference to #{verb}"
      help += ', or add one'
    @element.find('.help_banner_text').text help
