window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (@container, @id, @result_handler) ->
    if @container.find('.antcat-reference-picker').length is 0
      @container.append("<div class='antcat-reference-picker'></div>")
    @container.find('.antcat-reference-picker').load '/reference_pickers', id: @id, @setup_picker
    @

  setup_picker: =>
    @container.find('.antcat-reference-picker')

      .find(':button, :submit')
        .button()
        .end()

      .find(':button.close, :button.ok')
        .click =>
          @close()
          false
        .end()

      .find('form')
        .keypress (event) =>
          return true unless event.which is @ENTER
          @get_search_results()
          false

        .submit =>
          @get_search_results()
          false

        .find('#search_selector')
          .change ->
            new_type = $('#search_selector option:selected').text()
            if new_type is 'Search for'
              AntCat.ReferencePicker.remove_author_autocomplete()
              $('#search_selector').closest('form').removeAttr 'autocomplete'
            else
              AntCat.ReferencePicker.add_author_autocomplete($('#q'))
              $('#search_selector').closest('form').attr 'autocomplete', 'off'
            $('#q').focus()
          .end()
        .end()

      .find('.references')
        .selectable(filter: '.reference', stop: @enable_or_disable_ok_button)
        .end()

      .find("#reference_#{@id}")
        .addClass('ui-selected')
        .end()

      .show()

      .find('#q')
        .focus()

      AntCat.ReferencePicker.add_author_autocomplete @container.find('.antcat-reference-picker #q')

      @enable_or_disable_ok_button()

  enable_or_disable_ok_button: =>
    ok_button = @container.find '.antcat-reference-picker :button.ok'
    if @container.find('.antcat-reference-picker .ui-selected').length is 0
      ok_button.attr 'disabled', 'disabled'
    else
      ok_button.removeAttr 'disabled'

  get_search_results: =>
    @container.find('.antcat-reference-picker')
      .load '/reference_pickers',
            q: @container.find('.antcat-reference-picker #q').val(),
            search_selector: @container.find('.antcat-reference-picker #search_selector').val(),
            @setup_picker

  close: =>
    @container.find('.antcat-reference-picker').remove()
    @result_handler() if @result_handler

  @remove_author_autocomplete: ->
    $('#q').autocomplete 'destroy';

  @add_author_autocomplete: (field) =>
    return if AntCat.testing
    field.autocomplete
      selectFirst: true
      minLength: 3
      source: (request, response) ->
        search_term = AntCat.ReferencePicker.extract_author_search_term(@element.val(), $(@element).getSelection().start)
        if search_term.length >= 3
          $.getJSON "/authors/all",
            term: search_term
          , response
        else
          response []

    focus: ->
      false

    select: (event, ui) ->
      $this = $(@)
      value_and_position = AntCat.ReferencePicker.insert_author($this.val(), $this.getSelection().start, ui.item.value)
      $this.val value_and_position.string
      $this.setCaretPos value_and_position.position + 1
      false

  @extract_author_search_term: (string, position) =>
    return ""  if string.length is 0
    before_cursor = string.substring(0, position)
    last_semicolon = before_cursor.lastIndexOf(";")
    $.trim before_cursor.substring(last_semicolon + 1, position)

  @insert_author: (string, position, author) ->
    if string.length is 0
      return (
        string: string
        position: 0
      )
    before_cursor = string.substring(0, position)
    prior_semicolon = before_cursor.lastIndexOf(";")
    before_prior_semicolon = string.substring(0, prior_semicolon)
    before_prior_semicolon += "; "  if before_prior_semicolon.length > 0
    after_cursor = string.substring(position, string.length)
    string = before_prior_semicolon + author + "; " + $.trim(after_cursor)
    after_cursor = string.substring(position, string.length)
    next_semicolon = after_cursor.indexOf(";")
    position = next_semicolon + position + 2
    string: string
    position: position

  ENTER: 13

