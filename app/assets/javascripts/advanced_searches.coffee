$ ->
  $('#submit_button')
    .unbutton()
    .button()
    .click -> $('#submit_button').hide(); $('#throbber').show()
