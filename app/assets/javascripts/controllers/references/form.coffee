$ ->
  setupAdvancedAuthorAutocomplete()
  setupJournalAutocompletion()
  setupPublisherAutocompletion()

setupJournalAutocompletion = ->
  $('#reference_journal_name').autocomplete
    autoFocus: true
    source: '/journals/autocomplete.json'
    minLength: 1

setupPublisherAutocompletion = ->
  $('#reference_publisher_string').autocomplete
    autoFocus: true
    source: '/publishers/autocomplete.json'
    minLength: 1

setupAdvancedAuthorAutocomplete = ->
  $('#reference_author_names_string').autocomplete
    autoFocus: true
    minLength: 1
    source: (_request, response) ->
      selectionStart = AntCat.getInputSelection(@element.get(0), true)
      searchTerm = extractAuthorSearchTerm(@element.get(0).value, selectionStart)
      if searchTerm.length >= 1
        $.getJSON '/authors/autocomplete.json', { term: searchTerm }, response
      else
        response []
      return
    focus: -> false
    select: (_event, ui) ->
      $this = $(this)
      selectionStart = AntCat.getInputSelection($this.get(0), true)
      value_and_position = insertAuthor(@value, selectionStart, ui.item.value)
      @value = value_and_position.string
      false

extractAuthorSearchTerm = (string, position) ->
  return '' if string.length == 0

  beforeCursor = string.substring(0, position)
  lastSemicolon = beforeCursor.lastIndexOf(';')
  beforeCursor.substring(lastSemicolon + 1, position).trim()

insertAuthor = (string, position, author) ->
  return { string: string, position: 0 } if string.length == 0

  beforeCursor = string.substring(0, position)
  priorSemicolon = beforeCursor.lastIndexOf(';')
  beforePriorSemicolon = string.substring(0, priorSemicolon)
  if beforePriorSemicolon.length > 0
    beforePriorSemicolon += '; '
  afterCursor = string.substring(position, string.length)
  string = beforePriorSemicolon + author + '; ' + afterCursor.trim()
  afterCursor = string.substring(position, string.length)
  nextSemicolon = afterCursor.indexOf(';')
  position = nextSemicolon + position + 2

  { string: string, position: position }
