$ ->
  setupAdvancedAuthorAutocomplete()
  setupJournalAutocompletion()
  setupPublisherAutocompletion()

setupJournalAutocompletion = ->
  $('#reference_journal_name').autocomplete
    autoFocus: true
    source: '/journals/autocomplete'
    minLength: 1

setupPublisherAutocompletion = ->
  $('#reference_publisher_string').autocomplete
    autoFocus: true
    source: '/publishers/autocomplete'
    minLength: 1

setupAdvancedAuthorAutocomplete = ->
  $('#reference_author_names_string').autocomplete
    autoFocus: true
    minLength: 1
    source: (request, response) ->
      selectionStart = AntCat.getInputSelection(@element.get(0), true)
      searchTerm = extractAuthorSearchTerm(@element.val(), selectionStart)
      if searchTerm.length >= 3
        $.getJSON '/authors/autocomplete', { term: searchTerm }, response
      else
        response []
      return
    focus: -> false
    select: (event, ui) ->
      $this = $(this)
      selectionStart = AntCat.getInputSelection($this.get(0), true)
      value_and_position = insertAuthor(@value, selectionStart, ui.item.value)
      @value = value_and_position.string
      false

extractAuthorSearchTerm = (string, position) ->
  return '' if string.length == 0

  beforeCursor = string.substring(0, position)
  lastSemicolon = beforeCursor.lastIndexOf(';')
  $.trim beforeCursor.substring(lastSemicolon + 1, position)

insertAuthor = (string, position, author) ->
  return { string: string, position: 0 } if string.length == 0

  beforeCursor = string.substring(0, position)
  priorSemicolon = beforeCursor.lastIndexOf(';')
  beforePriorSemicolon = string.substring(0, priorSemicolon)
  if beforePriorSemicolon.length > 0
    beforePriorSemicolon += '; '
  afterCursor = string.substring(position, string.length)
  string = beforePriorSemicolon + author + '; ' + $.trim(afterCursor)
  afterCursor = string.substring(position, string.length)
  nextSemicolon = afterCursor.indexOf(';')
  position = nextSemicolon + position + 2

  { string: string, position: position }
