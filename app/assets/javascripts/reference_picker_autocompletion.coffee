window.AntCat or= {}

AntCat.reference_picker_setup_author_autocomplete = (field) ->
  return if AntCat.testing
  field.autocomplete
    selectFirst: true
    minLength: 3
    source: (request, response) ->
      search_term = AntCat.reference_picker_extract_author_search_term(@element.val(), $(@element).getSelection().start)
      if search_term.length >= 3
        $.getJSON "/authors/all",
          term: search_term
        , response
      else
        response []

    focus: ->
      false

    select: (event, ui) ->
      $this = $(this)
      value_and_position = AntCat.reference_picker_insert_author(@value, $this.getSelection().start, ui.item.value)
      @value = value_and_position.string
      $this.setCaretPos value_and_position.position + 1
      false

AntCat.reference_picker_setup_advanced_search_author_autocomplete = ->
  AntCat.reference_picker_setup_author_autocomplete $("#q")

AntCat.reference_picker_remove_advanced_search_author_autocomplete = ->
  $("#q").autocomplete "destroy"

AntCat.reference_picker_extract_author_search_term = (string, position) ->
  return ""  if string.length is 0
  before_cursor = string.substring(0, position)
  last_semicolon = before_cursor.lastIndexOf(";")
  $.trim before_cursor.substring(last_semicolon + 1, position)

AntCat.reference_picker_insert_author = (string, position, author) ->
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
