window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (parent, @reference_id, @result_handler) ->
    @create parent
    @load()
    @

  create: (parent) =>
    @widget = $("<div class='antcat-reference-picker ui-widget'></div>")
      .appendTo(parent)
      .append '<img src="/assets/ui-anim_basic_16x16.gif">'

  load: (url = '') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @reference_id if @reference_id
    #@widget.find('*').attr 'disabled', 'disabled'
    #@widget.fadeTo 0, 0.75
    #@widget.find('#throbber').show()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @widget.find('#throbber').hide()
        @widget.html data
        @setup()
      error: (xhr) => debugger

  search: =>
    @load $.param q: @textbox.val(), search_selector: @search_selector.val()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @widget.find('> .search_form').serialize()

  close: (cancel = false) =>
    if cancel
      taxt = null
    else
      selected_references = @widget.find '.selected_reference .reference'
      if selected_references.length > 0
        taxt = selected_references.first().data 'taxt'
      else
        taxt = 'No selection'
    @widget.remove()
    @result_handler taxt if @result_handler

  cancel: =>
    @close true

  setup: =>
    #@widget.fadeTo 0, 1.0

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
          @search_selector.closest('form').removeAttr 'autocomplete'
        else
          @enable_search_author_autocomplete()
          @search_selector.closest('form').attr 'autocomplete', 'off'
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
      .find(".search_results .reference_#{@reference_id} .reference_display")
        .addClass('ui-selected')
        .end()
      .find('.search_results')
        .selectable('destroy')
        .selectable(filter: '.reference_display', stop: @handle_new_selection, cancel: '.icons, .reference_edit')
        .end()
    @widget.find('.icon.edit').show() if AntCat.testing
    @widget.find('.icon.edit').click -> self.edit_reference this

  handle_new_selection: =>
    search_result = @selected_search_result()
    if search_result
      @widget.find('.selected_reference td').html search_result.clone(true).removeClass('ui-selected ui-selectee')
    @widget.toggleClass 'has-no-selection', not @selected_reference()
    @update_help_banner()

  selected_search_result: =>
    results = @widget.find '.search_results .reference_display.ui-selected'
    return if results.length is 0
    results.closest '.reference'

  selected_reference: =>
    references = @widget.find('.selected_reference .reference')
    return if references.length is 0
    references

  # -----------------------------------------
  enable_search_author_autocomplete: =>
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
    id = $reference.attr('id')
    selected_tab = $('.selected_tab', $reference).val()
    $('.tabs .article-tab', $reference).attr('href', '#reference_article' + id)
    $('.tabs .article-tab-section', $reference).attr('id', 'reference_article' + id)
    $('.tabs .book-tab', $reference).attr('href', '#reference_book' + id)
    $('.tabs .book-tab-section', $reference).attr('id', 'reference_book' + id)
    $('.tabs .nested-tab', $reference).attr('href', '#reference_nested' + id)
    $('.tabs .nested-tab-section', $reference).attr('id', 'reference_nested' + id)
    $('.tabs .unknown-tab', $reference).attr('href', '#reference_unknown' + id)
    $('.tabs .unknown-tab-section', $reference).attr('id', 'reference_unknown' + id)
    $('.tabs', $reference).tabs({selected: selected_tab})

  submit_reference_edit: (submit_button) =>
    $(submit_button).closest('form').ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update_reference
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
    help_verb = if @reference_id then 'use' else 'insert'
    any_search_results = @widget.find('.search_results .reference').length > 0
    if @selected_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = "Click OK to #{help_verb} this reference, or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to #{help_verb}"
      else
        help = "Find a reference to #{help_verb}"
    @widget.find('.help_banner .help_banner_text').text help

