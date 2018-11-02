$ ->
  setupReferenceTypeTabs()
  setupAutocompletion()

setupReferenceTypeTabs = ->
  referenceType = ->
    openTabId = $('#reference-tabs').find('.is-active a').attr('id')
    switch openTabId
      when 'tabs-article-label' then 'ArticleReference'
      when 'tabs-book-label'    then 'BookReference'
      when 'tabs-nested-label'  then 'NestedReference'
      when 'tabs-unknown-label' then 'UnknownReference'

  # Include reference type in the form before submitting.
  $('form.edit_reference, form.new_reference').submit -> $('#reference_type').val(referenceType)

setupJournalAutocompletion = ->
  $('#reference_journal_name').autocomplete
    autoFocus: true
    source: '/journals/autocomplete'
    minLength: 3

setupPublisherAutocompletion = ->
  $('#reference_publisher_string').autocomplete
    autoFocus: true
    source: '/publishers/autocomplete'
    minLength: 3

setupAdvancedAuthorAutocomplete = ->
  $('#reference_author_names_string').autocomplete
    autoFocus: true
    minLength: 3
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

  {
    string: string
    position: position
  }

setupAutocompletion = ->
  setupAdvancedAuthorAutocomplete()
  setupJournalAutocompletion()
  setupPublisherAutocompletion()
