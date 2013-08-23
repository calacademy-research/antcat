$ ->
  $('#submit_button')
    .unbutton()
    .button()
    .click -> $('#submit_button').hide(); $('#throbber').show()
  setup_author_autocomplete()

setup_author_autocomplete = ->
  return if AntCat.testing
  $('#author_name').autocomplete
    autoFocus: true,
    source: "/authors/all",
    minLength: 3
