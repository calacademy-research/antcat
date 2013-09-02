$ ->
  setup_buttons()
  setup_author_autocomplete()

setup_buttons = ->
  $('#go_button')
    .unbutton()
    .button()
    .click -> $('#go_button').hide(); $('#throbber').show()
  $('#download_button')
    .unbutton()
    .button()
    .click ->
      $('#download_button').hide(); $('#throbber').show()
      window.location = $('#download_button').data('location')

setup_author_autocomplete = ->
  return if AntCat.testing
  $('#author_name').autocomplete
    autoFocus: true,
    source: "/authors/all",
    minLength: 3
