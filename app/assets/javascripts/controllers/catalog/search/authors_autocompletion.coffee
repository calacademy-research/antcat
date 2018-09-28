$ ->
  setup_author_autocomplete()

setup_author_autocomplete = ->
  $('#author_name-js-hook').autocomplete
    autoFocus: true
    source: '/authors/autocomplete'
    minLength: 3
