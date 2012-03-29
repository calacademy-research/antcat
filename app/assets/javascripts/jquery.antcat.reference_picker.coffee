window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (parent, @reference_id, @result_handler) ->
    @widget = $("<div class='antcat-reference-picker'></div>")
      .appendTo(parent)
      .load '/reference_pickers', id: @reference_id, @setup_picker
    @

  setup_picker: =>
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

      .find('.references')
        .selectable(filter: '.reference', stop: @enable_or_disable_ok_button)
        .end()

      .find("#reference_#{@reference_id}")
        .addClass('ui-selected')
        .end()

      .show()

    @search_selector
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
    @enable_or_disable_ok_button()
    @textbox.focus()

  enable_or_disable_ok_button: =>
    ok_button = @widget.find ':button.ok'
    if @widget.find('.ui-selected').length is 0
      ok_button.attr 'disabled', 'disabled'
    else
      ok_button.removeAttr 'disabled'

  search: =>
    @widget
      .load '/reference_pickers',
            q: @textbox.val(),
            search_selector: @search_selector.val(),
            @setup_picker

  close: =>
    @widget.remove()
    @result_handler() if @result_handler

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

    focus: ->
      false # don't update the search textbox when the autocomplete item changes

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

