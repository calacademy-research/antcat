$ ->
  $(".history-items #select-all-history-items").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', true)

  $(".history-items #unselect-all-history-items").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', false)
