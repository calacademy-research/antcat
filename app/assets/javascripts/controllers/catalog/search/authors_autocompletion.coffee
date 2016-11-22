$ ->
  setup_author_autocomplete()

setup_author_autocomplete = ->
  return if AntCat.testing
  $('#author_name-js-hook').autocomplete
    autoFocus: true
    source: '/authors/autocomplete'
    minLength: 3
