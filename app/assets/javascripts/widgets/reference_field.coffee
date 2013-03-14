class AntCat.ReferenceField extends AntCat.FieldPanel

  constructor: (@parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super @parent_element.find('> .antcat_reference_field'), @options

  create_form: ($element, options) =>
    options.button_container = '.controls'
    new AntCat.ReferenceFieldForm $element, options

  form: =>
    @_form or= @create_form @expansion,
      on_open:              @on_form_open
      on_close:             @on_form_close
      on_response:          @on_form_response
      on_success:           @on_form_success
      on_cancel:            @on_form_cancel
      on_application_error: @on_application_error
      before_submit:        @before_submit

  initialize: ($element) =>
    super

    @element.addClass 'modal' unless @options.field

    @edit = @element.find '> .edit'
    AntCat.log 'ReferenceField initialize: @edit.size() != 1' unless @edit.size() == 1
    @expansion = @edit.find '> .expansion'
    AntCat.log 'ReferenceField initialize: @expansion.size() != 1' unless @expansion.size() == 1
    @display = @element.find '> .display'
    AntCat.log 'ReferenceField initialize: @display.size() != 1' unless @display.size() == 1
    @template = @element.find '> .template'
    AntCat.log 'ReferenceField initialize: @template.size() != 1' unless @template.size() == 1
    @current = @edit.find '> .current'
    AntCat.log 'ReferenceField initialize: @current.size() != 1' unless @current.size() == 1
    @search_selector = @expansion.find '.search_selector'
    AntCat.log 'ReferenceField initialize: @search_selector.size() != 1' unless @search_selector.size() == 1
    @textbox = @expansion.find '.q'
    AntCat.log 'ReferenceField initialize: @textbox.size() != 1' unless @textbox.size() == 1

    @setup_controls()
    @setup_references()
    @handle_new_selection()

  search_results: =>
    @expansion.find '> .search_results'

  show_form: =>
    super
    @setup_search_selector()

  load: (url = '') =>
    if url.indexOf('/reference_field') is -1
      url = '/reference_field?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        $element = @parent_element.find('> .antcat_reference_field')
        @initialize $element
        @show_form()
      error: (xhr) => debugger

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .expansion .controls').disable()

  #---------------------------------
  search: =>
    @load @get_search_parameters()

  load_clicked_page: (link) =>
    @load $(link).attr('href') + '&' + @get_search_parameters()

  get_search_parameters: =>
    $.param q: @textbox.val(), search_selector: @search_selector.val()

  ok: =>
    @set_value @id
    @set_display_text()
    @close()

  cancel: =>
    @clear_current()
    @close()

  close: =>
    @hide_form()
    @options.on_close() if @options.on_close

  setup_controls: =>
    self = @
    @expansion
      .find('.controls')
        .undisable()
        .find(':button')
          .unbutton()
          .button()
          .end()
        .end()

      .find(':button.ok')
        .click =>
          @ok()
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

  enable_controls: => @expansion.find('.controls').undisable()
  disable_controls: => @expansion.find('.controls').disable()

  # -----------------------------------------
  add_reference: =>
    @make_current @template.find('.reference'), true

  setup_references: =>
    @element
      .find('.reference').reference_panel(
          on_form_open:  @on_reference_form_open
          on_form_close: @on_reference_form_close
          on_form_done:  @on_reference_form_done)
        .end()

    @search_results()
      .find(".reference .item_#{@id} div.display")
        .addClass('ui-selected')
        .end()

    @element.find('.search_results div.display').bind 'click', @handle_click
    @element.find('.search_results div.display').hover(@hover, @unhover)

  hover: (event) =>
    AntCat.deselect()
    $target = $(event.target)
    $target = $target.closest('.display') unless $target.hasClass('display')
    $target.select()
  unhover: (event) =>
    AntCat.deselect()

  handle_click: (event) =>
    @element.find('div.display').removeClass('ui-selected')
    AntCat.deselect()
    $(event.target).addClass('ui-selected')
    @handle_new_selection()

  on_reference_form_open: => @disable_controls()
  on_reference_form_close: => @enable_controls()
  on_reference_form_done: ($panel) =>
    id = $panel.data 'id'
    $(".item_#{id}").each -> $(@).replaceWith $panel.clone()
    @setup_references()

  # 'current' is the reference panel at the top of the field, above the controls
  # too much duplication between this and setup_references
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
    @element.find('div.display').bind 'click', @handle_click
    @element.find('div.display').hover(@hover, @unhover)
    @element.removeClass 'has_no_current_reference'

  handle_new_selection: =>
    $selected_reference = @selected_reference()
    @make_current $selected_reference if $selected_reference

    @id = if @current_reference() then @current_reference().data 'id' else null
    @element.toggleClass 'has_no_current_reference', not @current_reference()
    @update_help()
    @options.on_change(@value()) if @options.on_change

  value: =>
    $value_field = $('#' + @value_id)
    AntCat.log 'ReferenceField get_value: $value_field.size() != 1' unless $value_field.size() == 1
    $value_field.val

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    AntCat.log 'ReferenceField set_value: $value_field.size() != 1' unless $value_field.size() == 1
    $value_field.val value

  set_display_text: =>
    reference_text = @current_reference().find('.display').text()
    @display.find('.display_button').text reference_text

  selected_reference: =>
    results = @search_results().find 'div.display.ui-selected'
    return if results.length is 0
    results.closest '.reference'

  current_reference: =>
    reference = @current.find('.reference')
    return if reference.length is 0
    return unless reference.data 'id'
    reference

  clear_current: =>
    $('.ui-selected').removeClass('ui-selected')
    @current = @element.find '> .current'
    @current.find(".item_#{@id} .reference_item").replaceWith('<div class="reference"><table class="reference_table"><tr><td class="reference_item"><div class="display">(none)</div></td></tr></table></div>')

  # -----------------------------------------
  enable_search_author_autocomplete: =>
    return if AntCat.testing
    @enable_browser_autocomplete false
    @textbox.autocomplete
      autoFocus: true
      minLength: 3
      source: (request, result_handler) ->
        search_term = AntCat.ReferenceField.extract_author_search_term(@element.val(), $(@element).getSelection().start)
        if search_term.length >= 3
          $.getJSON "/authors/all", term: search_term, result_handler
        else
          result_handler []
      # don't update the search textbox when the autocomplete item changes
      focus: -> false
      select: (event, data) ->
        $this = $(@)
        value_and_position = AntCat.ReferenceField.insert_author($this.val(), $this.getSelection().start, data.item.value)
        $this.val value_and_position.string
        $this.setCaretPos value_and_position.position + 1
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
  update_help: =>
    any_search_results = @search_results().find('.reference').length > 0
    if @current_reference()
      if any_search_results
        other_verb = 'choose'
      else
        other_verb = 'search for'
      help = "Click OK to use"
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

# -----------------------------------------
class AntCat.ReferenceFieldForm extends AntCat.NestedForm
