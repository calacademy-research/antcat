(() => {
  const extractAuthorSearchTerm = (string, position) => {
    if (string.length === 0) return ''

    const beforeCursor = string.substring(0, position)
    const lastSemicolon = beforeCursor.lastIndexOf(';')
    return beforeCursor.substring(lastSemicolon + 1, position).trim()
  }

  const insertAuthor = (string, position, author) => {
    if (string.length === 0) return { string, position: 0 }

    const beforeCursor = string.substring(0, position)
    const priorSemicolon = beforeCursor.lastIndexOf(';')
    let beforePriorSemicolon = string.substring(0, priorSemicolon)
    if (beforePriorSemicolon.length > 0) {
      beforePriorSemicolon += '; '
    }
    const newString = `${beforePriorSemicolon}${author}; ${string.substring(position, string.length).trim()}`
    const afterCursor = newString.substring(position, newString.length)
    const nextSemicolon = afterCursor.indexOf(';')

    return { string: newString, position: nextSemicolon + position + 2 }
  }

  const setupJournalAutocompletion = () => {
    $('#reference_journal_name').autocomplete({
      autoFocus: true,
      source: '/journals/autocomplete.json',
      minLength: 1,
    })
  }

  const setupPublisherAutocompletion = () => {
    $('#reference_publisher_string').autocomplete({
      autoFocus: true,
      source: '/publishers/autocomplete.json',
      minLength: 1,
    })
  }

  const setupAdvancedAuthorAutocomplete = () => {
    $('#reference_author_names_string').autocomplete({
      autoFocus: true,
      minLength: 1,
      // `this` is the jQuery UI autocomplete instance.
      source(_request, response) {
        const selectionStart = AntCat.getInputSelection(this.element.get(0), true)
        const searchTerm = extractAuthorSearchTerm(this.element.get(0).value, selectionStart)
        if (searchTerm.length >= 1) {
          $.getJSON('/authors/autocomplete.json', { term: searchTerm }, response)
        } else {
          response([])
        }
      },
      focus: () => false,
      // `this` is the input element.
      select(_event, ui) {
        const selectionStart = AntCat.getInputSelection(this, true)
        const valueAndPosition = insertAuthor(this.value, selectionStart, ui.item.value)
        this.value = valueAndPosition.string
        return false
      },
    })
  }

  $(() => {
    setupAdvancedAuthorAutocomplete()
    setupJournalAutocompletion()
    setupPublisherAutocompletion()
  })
})()
