$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $('.authors-autocompletion').autocomplete
    autoFocus: true
    minLength: 3
    source: '/authors/autocomplete'
