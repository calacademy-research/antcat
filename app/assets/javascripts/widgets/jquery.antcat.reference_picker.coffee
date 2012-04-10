window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (parent, @reference_id, @result_handler) ->
    @widget = $("<div class='antcat-reference-picker ui-widget'></div>")
    @widget.appendTo(parent)
    @widget.show()
    @widget.append('<img src="/assets/ui-anim_basic_16x16.gif">')
    @load()
    @help_verb = if @reference_id then 'use' else 'insert'
    @

  initialize: =>
    @widget.fadeTo 0, 1.0
    @current_selection = null

    self = @
    @textbox = @widget.find '#q'
    @search_selector = @widget.find '#search_selector'

    @widget
      .find(':button, :submit')
        .button()
        .end()
      .find(':button.ok, :button.close')
        .click =>
          @close()
          false
        .end()
      .find('form')
        .keypress (event) =>
          return true unless event.which is @ENTER
          @search()
          false
        .submit =>
          @search()
          false
        .end()
      .find('.search_results')
        .selectable(filter: '.reference', stop: @handle_new_selection, cancel: '.ui-selected')
        .end()
      .find('.reference')
        .dblclick =>
          @close()
          false
        .end()
      .find(".selected_reference, .search_results #reference_#{@reference_id}")
        .addClass('ui-selected')
        .end()
      .find('.pagination a')
        .click ->
          self.load_clicked_page this
          false
        .end()
      .find('.search_form#q')
        .focus()

    @setup_edit_icons()
    @setup_edits()

    @search_selector
      .selectmenu(wrapperElement: "<span />")
      .change =>
        new_type = @search_selector.find('option:selected').text()
        if new_type is 'Search for'
          @disable_author_autocomplete()
          @search_selector.closest('form').removeAttr 'autocomplete'
        else
          @enable_author_autocomplete()
          @search_selector.closest('form').attr 'autocomplete', 'off'
        @textbox.focus()

    @enable_author_autocomplete()
    @handle_new_selection()

    @widget.show()
    @textbox.focus()

  load: (url = '') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @reference_id if @reference_id
    @widget.find('*').attr 'disabled', 'disabled'
    @widget.fadeTo 0, 0.75
    @widget.find('#throbber').show()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @widget.find('#throbber').hide()
        @widget.html data
        @initialize()
      error: (xhr) => debugger

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @widget.find('> form').serialize()

  selected_search_result: =>
    results = @widget.find '.search_results .reference.ui-selected'
    return if results.length is 0
    results.first()

  selected_reference: =>
    references = @widget.find('.selected_reference .reference')
    return if references.length is 0
    references.first()

  handle_new_selection: =>
    search_result = @selected_search_result()
    if search_result
      @widget.find('.selected_reference td').html search_result.clone(true).removeClass('ui-selected ui-selectee')
    @widget.toggleClass 'has-no-selection', not @selected_reference()
    @update_help_banner()

  update_help_banner: =>
    any_search_results = @widget.find('.search_results .reference').length > 0
    if @selected_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = "Click OK to #{@help_verb} this reference, or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to #{@help_verb}"
      else
        help = "Find a reference to #{@help_verb}"
    @widget.find('.help_banner .help_banner_text').text help

  search: =>
    @load $.param q: @textbox.val(), search_selector: @search_selector.val()

  close: =>
    selected_references = @widget.find '.selected_reference .reference'
    if selected_references.length > 0
      taxt = selected_references.first().data 'taxt'
    else
      taxt = 'No selection'
    @widget.remove()
    @result_handler(taxt) if @result_handler

  enable_author_autocomplete: =>
    return if AntCat.testing
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

    select: (event, data) =>
      value_and_position = AntCat.ReferencePicker.insert_author(@textbox.val(), @textbox.getSelection().start, data.item.value)
      @textbox.val value_and_position.string
      @textbox.setCaretPos value_and_position.position + 1
      false

  disable_author_autocomplete: =>
    @textbox.autocomplete 'destroy'

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

  ENTER: 13

  # -----------------------------------------
  setup_edit_icons: =>
    self = @
    $('.icon').show() if AntCat.testing
    $('.reference')
      .live('mouseenter', -> $('.icon', $(this)).show() unless self.is_editing())
      .live('mouseleave', -> $('.icon').hide())
    $('.icon.edit').live 'click', -> self.edit_reference this

  setup_edits: =>
    $('.reference_edit').hide()
    $('.reference_edit .submit').live('click', @submit_reference_edit)
    $('.reference_edit .cancel').live('click', @cancel_reference_edit)

  submit_reference_edit: =>
    false

  cancel_reference_edit: =>
    false

  edit_reference: (icon) ->
    return if @is_editing()
    $reference = $(icon).closest '.reference'
    #saveReference($reference)
    @show_reference_edit $reference
    false

  show_reference_edit: ($reference) =>
    $('.reference_display', $reference).hide()
    $('.icon', $reference).hide() unless AntCat.testing

    $edit = $('.reference_edit', $reference)

    #setupTabs($reference)

    #setupReferenceEditAuthorAutocomplete($reference)
    #setupReferenceEditJournalAutocomplete($reference)
    #setupReferenceEditPublisherAutocomplete($reference)

    $edit.show()
    @fade_everything_but $reference
    $edit.find('input[type=text]:first').focus()
  
  fade_everything_but: ($element) =>
    while true
      $element.siblings().fadeTo 'fast', 0.4
      $element = $element.parent()
      break if $element.hasClass 'antcat-reference-picker'

  is_editing: =>
    @widget.find('.reference_edit:visible').length > 0
