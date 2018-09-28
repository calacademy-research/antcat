$ ->
  $(".history-items #select-all").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', true)

  $(".history-items #unselect-all").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', false)
