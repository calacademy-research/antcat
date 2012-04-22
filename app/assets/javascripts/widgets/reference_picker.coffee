class AntCat.ReferencePicker

  constructor: (parent, @original_reference_id, @result_handler) ->
    @current_reference_id = @original_reference_id
    @create parent
    @load()
    @

  create: (parent) =>
    @widget = $('<div/>').addClass 'antcat-reference-picker ui-widget ui-widget-content ui-corner-all'
    @widget.append @bootstrap_help_banner()
    @widget.appendTo parent

  bootstrap_help_banner: =>
    $form = $('<form/>').addClass 'search_form'
    $table = $('<table/>').appendTo $form
    $tr     = $('<tr/>').appendTo $table
    $td       = $('<td/>').addClass('throbber').appendTo $tr
    $throbber   = $('<div/>').addClass('throbber').appendTo $form
    $td       = $('<td/>').appendTo $tr
    $div        = $('<div/>').addClass('ok_cancel_controls').appendTo $td
    $div        = $('<div/>').addClass('search_controls').appendTo $td
    $div        = $('<div/>').addClass('pagination').appendTo $td
    $help_banner= $('<div/>').addClass('help_banner').appendTo($td)
    help_banner_text = $('<span/>').addClass('help_banner_text').appendTo($help_banner)
    $form

  load: (url = '') =>
    if url.indexOf('/reference_picker') is -1
      url = '/reference_picker?' + url
    url = url + '&' + $.param id: @current_reference_id if @current_reference_id

    $throbber_image = @widget.find('.throbber img')
    if $throbber_image.length > 0
      @widget.find('.help_banner_text').html('')
      $throbber_image.show()
    else
      @widget.find('.help_banner_text').html 'Loading&hellip;'
    @widget.find('.search_form .controls').disable()

    # debug code to leave throbber up for a little while
    setTimeout(=> $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @widget.html data
        @initialize()
      error: (xhr) => debugger
    0)

  search: =>
    @load $.param q: @textbox.val(), search_selector: @search_selector.val()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @widget.find('> .search_form').serialize()

  close: (cancel = false) =>
    taxt = if not cancel and @current_reference() then @current_reference().data 'taxt' else null
    @widget.slideUp 'fast', =>
      @widget.remove()
      @result_handler taxt if @result_handler

  cancel: =>
    @close true

  initialize: =>
    @search_selector = @widget.find '.search_selector'
    @textbox = @widget.find '.q'

    @setup_search()
    @setup_references()
    @handle_new_selection()
    @textbox.focus()

  setup_search: =>
    self = @
    @widget.find('.search_form')
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
    @widget
      .find('.reference').reference_panel()
        .end()
      .find(".search_results .reference_#{@current_reference_id} .reference_display")
        .addClass('ui-selected')
        .end()
      .find('.search_results')
        .selectable('destroy')
        .selectable(filter: '.reference_display', stop: @handle_new_selection, cancel: '.icons, .reference_edit')
        .end()

  handle_new_selection: =>
    selected_reference = @selected_reference()
    if selected_reference
      @widget
        .find('.current_reference td')
          .html(selected_reference.clone(true).removeClass 'ui-selected ui-selectee')
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
  add: =>
    $reference = @widget.find('.template .reference').clone()
    @widget.find('.current_reference td').html $reference
    $reference = @widget.find('.current_reference .reference')
    @current_reference_id = null
    @open_form $reference
    @widget.toggleClass 'has-no-current-reference', false
    false

  submit_form: (submit_button) =>
    $(submit_button).closest('.spinner_container')
      .spinner
        position: 'left'
        img: '/assets/ui-anim_basic_16x16.gif'
      .find('button')
        .disable()

    $(submit_button).closest('form').ajaxSubmit
      beforeSerialize: @before_serialize
      success: @handle_submit_response
      error: (->)
      dataType: 'json'
    false

  before_serialize: ($form, options) =>
    selectedTab = $.trim($('.ui-tabs-selected', $form).text())
    $('#selected_tab', $form).val selectedTab
    true

  handle_submit_response: (data, statusText, xhr, $form) =>
    reference_selector = if data.isNew then '.current_reference .reference' else ".reference_#{data.id}"
    @update_form $(reference_selector), data.content
    unless data.success
      @open_form @widget.find reference_selector
      return
    @setup_references()
    @widget.find(reference_selector).effect("highlight", {color: 'darkgreen'}, 3000)
    @widget.find('.search_form .controls').removeClass 'ui-state-disabled'
    $edit.find('.icon.edit').show() if AntCat.testing

  update_form: ($reference, content) =>
    $reference
      .find('.spinner_container')
        .spinner('remove')
        .end()
      .each -> $(@).parent().html content

  cancel_form: =>
    false

  # -----------------------------------------
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
      help = "Click OK to #{verb} this reference, or add or #{other_verb} a different one"
    else
      if any_search_results
        help = "Choose a reference to #{verb}"
      else
        help = "Find a reference to #{verb}"
      help += ', or add one'
    @widget.find('.help_banner_text').text help

# ---------------------------------------
class AntCat.ReferencePanel extends AntCat.Panel
  create_form: ($element, options) => new AntCat.ReferenceForm $element, options
  setup_form: => @element.find('.search_form .controls').disable()

$.fn.reference_panel = (options = {}) ->
  return this.each -> new AntCat.ReferencePanel $(this), options

# ---------------------------------------
class AntCat.ReferenceForm extends AntCat.Form

  setup: =>
    @setup_author_autocomplete()
    @setup_journal_autocomplete()
    @setup_publisher_autocomplete()
    @setup_tabs()

  setup_tabs: =>
    $tabs = @element.find '.tabs'
    $tabs.tabs 'destroy'
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
    $tabs.tabs selected: @element.find('.selected_tab').val()

  setup_author_autocomplete: =>
    return if AntCat.testing
    @element.find('.authors').autocomplete
      autoFocus: true
      minLength: 3
      source: (request, result_handler) ->
        search_term = AntCat.ReferencePicker.extract_author_search_term(@element.val(), $(@element).getSelection().start)
        if search_term.length >= 3
          $.getJSON "/authors/all", term: search_term, result_handler
        else
          result_handler []
      focus: -> false # don't update the search textbox when the autocomplete item changes
      select: (event, data) ->
        value_and_position = AntCat.ReferencePicker.insert_author($(@).val(), $(@).getSelection().start, data.item.value)
        $(@).val value_and_position.string
        $(@).setCaretPos value_and_position.position + 1
        false

  setup_journal_autocomplete: =>
    @element.find('.journal').autocomplete
      autoFocus: true,
      source: "/journals",
      minLength: 3

  setup_publisher_autocomplete: =>
    @element.find('.publisher').autocomplete
      autoFocus: true,
      source: "/publishers",
      minLength: 3
