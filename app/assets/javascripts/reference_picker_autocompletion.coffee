window.AntCat or= {}

AntCat.reference_picker_setupAuthorAutocomplete = (field) ->
  return if AntCat.testing
  field.autocomplete
    selectFirst: true
    minLength: 3
    source: (request, response) ->
      searchTerm = AntCat.reference_picker_extractAuthorSearchTerm(@element.val(), $(@element).getSelection().start)
      if searchTerm.length >= 3
        $.getJSON "/authors/all",
          term: searchTerm
        , response
      else
        response []

    focus: ->
      false

    select: (event, ui) ->
      $this = $(this)
      value_and_position = AntCat.reference_picker_insertAuthor(@value, $this.getSelection().start, ui.item.value)
      @value = value_and_position.string
      $this.setCaretPos value_and_position.position + 1
      false
AntCat.reference_picker_setupAdvancedSearchAuthorAutocomplete = ->
  AntCat.reference_picker_setupAuthorAutocomplete $("#q")
AntCat.reference_picker_removeAdvancedSearchAuthorAutocomplete = ->
  $("#q").autocomplete "destroy"
AntCat.reference_picker_setupReferenceEditAuthorAutocomplete = ($reference) ->
  AntCat.reference_picker_setupAuthorAutocomplete $(".reference_edit .authors", $reference)
AntCat.reference_picker_extractAuthorSearchTerm = (string, position) ->
  return ""  if string.length is 0
  beforeCursor = string.substring(0, position)
  lastSemicolon = beforeCursor.lastIndexOf(";")
  $.trim beforeCursor.substring(lastSemicolon + 1, position)
AntCat.reference_picker_insertAuthor = (string, position, author) ->
  if string.length is 0
    return (
      string: string
      position: 0
    )
  beforeCursor = string.substring(0, position)
  priorSemicolon = beforeCursor.lastIndexOf(";")
  beforePriorSemicolon = string.substring(0, priorSemicolon)
  beforePriorSemicolon += "; "  if beforePriorSemicolon.length > 0
  afterCursor = string.substring(position, string.length)
  string = beforePriorSemicolon + author + "; " + $.trim(afterCursor)
  afterCursor = string.substring(position, string.length)
  nextSemicolon = afterCursor.indexOf(";")
  position = nextSemicolon + position + 2
  string: string
  position: position
