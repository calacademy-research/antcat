$ ->
  setupAuthorAutocomplete()
  setupCloseLinks()

setupCloseLinks = ->
  $('.close_link').click ->
    $(this).closest('form').submit()
    false

setupAuthorAutocomplete = ->
  return if AntCat.testing
  $('input[type=text]').autocomplete
    autoFocus: true
    minLength: 3
    source: '/authors/autocomplete'
