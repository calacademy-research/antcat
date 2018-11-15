$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $('#author_name-js-hook').autocomplete
    autoFocus: true
    source: '/authors/autocomplete'
    minLength: 3
