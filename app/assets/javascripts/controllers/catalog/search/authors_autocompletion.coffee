$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $('#author_name-js-hook').autocomplete
    autoFocus: true
    source: '/authors/autocomplete.json'
    minLength: 1
