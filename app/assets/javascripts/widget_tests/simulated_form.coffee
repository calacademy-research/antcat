$ ->
  $('.simulated_form :button, .simulated_form :submit').click ->
    $form = $('form.test')
    $form.action = '/widget_tests/simulated_form'
    $form.ajaxSubmit
      #beforeSerialize: -> console.log 'beforeSerialize'
      success: -> console.log 'success'
      error: (jq_xhr, text_status, error_thrown) ->
        console.log error_thrown
      type: 'POST'
    false
