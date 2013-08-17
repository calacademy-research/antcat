$ ->
  $('#approve_button')
    .unbutton()
    .button()
    .click -> window.location = $(@).data('approve-location')
