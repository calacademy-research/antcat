$ ->
  setup_buttons()
  setup_author_autocomplete()

setup_buttons = ->
  $('.search_section #go_button')
    .button()
    .click ->
      $('.search_section .go_button').hide()
      $('.search_section .throbber').show()

  $('.results_section #download_button')
    .button()
    .click -> window.location = $('.results_section #download_button').data('location')

setup_author_autocomplete = ->
  return if AntCat.testing
  $('#author_name').autocomplete
    autoFocus: true,
    source: "/authors/all",
    minLength: 3
