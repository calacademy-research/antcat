$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $('input[type=text]').autocomplete
    autoFocus: true
    minLength: 3
    source: '/authors/autocomplete'
