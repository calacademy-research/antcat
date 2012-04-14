window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (parent, @original_reference_id, @result_handler) ->
    @current_reference_id = @original_reference_id
    @create parent
    @load()
    @

  create: (parent) =>
    @widget = $('<div/>').addClass 'antcat-reference-picker ui-widget ui-widget-content ui-corner-all'
    @widget.append @help_banner_bootstrap()
    @widget.appendTo parent

  help_banner_bootstrap: =>
    help_banner_text = $('<span/>')
      .addClass('help_banner_text')
      .html('Loading&hellip;')
    $('<div/>')
      .addClass('help_banner')
      .append help_banner_text

  load: (url = '') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @current_reference_id if @current_reference_id

    @widget
      .find('.throbber img')
        .show()
        .end()
      .find('.search_form .controls')
        .addClass('ui-state-disabled')
        .end()

    # debug code to leave throbber up for a little while
    #setTimeout(=> $.ajax
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @widget.html data
        @setup()
      error: (xhr) => debugger
    #2000)

  search: =>
    @load $.param q: @textbox.val(), search_selector: @search_selector.val()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @widget.find('> .search_form').serialize()

  close: (cancel = false) =>
    taxt = if not cancel and @current_reference() then @current_reference().data 'taxt' else null
    @widget.remove()
    @result_handler taxt if @result_handler

  cancel: =>
    @close true

  setup: =>
    @search_selector = @widget.find '.search_selector'
    @textbox = @widget.find '.q'

    @setup_search_form()
    @setup_references()
    @handle_new_selection()
    @textbox.focus()

  setup_search_form: =>
    self = @
    @widget.find('.search_form')
      .submit =>
        @search()
        false
      .keypress (event) =>
        return true unless event.which is @ENTER
        @search()
        false
      .find(':button, :submit')
        .button()
        .end()
      .find(':button.ok')
        .click =>
          @close()
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
    @widget
      .find('.reference')
        .mouseenter((-> $('.icon.edit', $(this)).show() unless self.is_editing()))
        .mouseleave((-> $('.icon.edit').hide()))
        .dblclick =>
          @close()
          false
        .end()
      .find(".search_results .reference_#{@current_reference_id} .reference_display")
        .addClass('ui-selected')
        .end()
      .find('.search_results')
        .selectable('destroy')
        .selectable(filter: '.reference_display', stop: @handle_new_selection, cancel: '.icons, .reference_edit')
        .end()
    @widget.find('.icon.edit').show() if AntCat.testing
    @widget.find('.icon.edit').click -> self.edit_reference this

  handle_new_selection: =>
    selected_reference = @selected_reference()
    if selected_reference
      @widget
        .find('.current_reference td')
          .html(selected_reference.clone(true).removeClass 'ui-selected ui-selectee')
          .find('.reference_display')
            .effect("highlight", {color: 'lightgreen'}, 3000)
    @current_reference_id = if @current_reference() then @current_reference().data 'reference-id' else null
    @widget.toggleClass 'has-no-current-reference', not @current_reference()
    @update_help_banner()

  selected_reference: =>
    results = @widget.find '.search_results .reference_display.ui-selected'
    return if results.length is 0
    results.closest '.reference'

  current_reference: =>
    references = @widget.find('.current_reference .reference')
    return if references.length is 0
    references

  # -----------------------------------------
  enable_search_author_autocomplete: =>
    @search_selector.closest('form').attr 'autocomplete', 'off'
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

  ENTER: 13

  # -----------------------------------------
  edit_reference: (icon) ->
    return if @is_editing()
    $reference = $(icon).closest '.reference'
    #saveReference($reference)
    @show_reference_form $reference
    false

  show_reference_form: ($reference) =>
    self = @
    $edit = $reference.find '.reference_edit'

    $edit
      .find(':button, :submit')
        .button()
        .end()
      .find('.submit')
        .click ->
          self.submit_reference_edit this
        .end()
      .find('.cancel')
        .click(@cancel_reference_edit)
        .end()
      .find('.delete')
        .hide()
        .end()

    @setup_tabs $reference

    #setupReferenceEditAuthorAutocomplete($reference)
    #setupReferenceEditJournalAutocomplete($reference)
    #setupReferenceEditPublisherAutocomplete($reference)

    #@set_sibling_opacity $edit, '.3'

    $edit.find('.icon.edit').hide() unless AntCat.testing

    $reference.find('.reference_display').hide()
    $edit
      .show()
      .find('input[type=text]:first')
        .focus()

  setup_tabs: ($reference) =>
    $tabs = $reference.find '.tabs'

    $tabs.find('> ul').remove()
    $list = $('<ul/>').prependTo $tabs

    $tabs.find('.tabbable').each ->
      id = 'A' + Math.random().toString().replace '.', ''
      $list_item = $('<li/>').appendTo $list
      $a = $('<a/>')
        .appendTo($list_item)
        .text($(this).data('title'))
        .attr 'href', '#' + id
      $(this).attr 'id', id

    $tabs.tabs selected: $reference.find('.selected_tab').val()

  submit_reference_edit: (submit_button) =>
    $(submit_button).closest('form').ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update_reference
      error: (->)
      dataType: 'json'
    false

  before_serialize: ($form, options) =>
    selectedTab = $.trim($('.ui-tabs-selected', $form).text())
    $('#selected_tab', $form).val selectedTab
    true

  update_reference: (data, statusText, xhr, $form) =>
    id = '.reference_' + if data.isNew then '' else data.id
    $(id).each -> $(@).parent().html data.content
    $reference = $ id

    @setup_references()

    #$spinnerElement = $('button', $edit).parent()
    #$('input', $spinnerElement).attr('disabled', '')
    #$('button', $spinnerElement).attr('disabled', '')
    #$spinnerElement.spinner('remove')

    unless data.success
      @show_reference_form $reference
      return

    $reference
      .find('.reference_edit')
        .hide()
        .end()
      .find('.reference_display')
        .show()
        .effect("highlight", {}, 3000)

    $edit.find('.icon.edit').show() if AntCat.testing

    #@set_sibling_opacity $edit, '1'

  cancel_reference_edit: =>
    false

  # -----------------------------------------
  set_sibling_opacity: ($element, opacity) =>
    while not $element.hasClass 'antcat-reference-picker'
      $element.siblings().css 'opacity', opacity
      $element = $element.parent()

  is_editing: =>
    @widget.find('.reference_edit:visible').length > 0

  update_help_banner: =>
    verb = if @original_reference_id then 'use' else 'insert'
    any_search_results = @widget.find('.search_results .reference').length > 0
    if @current_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = "Click OK to #{verb} this reference, or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to #{verb}"
      else
        help = "Find a reference to #{verb}"
    @widget.find('.help_banner_text').text help

