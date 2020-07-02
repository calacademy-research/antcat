$ ->
  $(".history-items #select-all-history-items").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', true)

  $(".history-items #unselect-all-history-items").click (event) ->
    event.preventDefault()
    $(".history-items input:checkbox").prop('checked', false)

  $(".reference-sections #select-all-reference-sections").click (event) ->
    event.preventDefault()
    $(".reference-sections input:checkbox").prop('checked', true)

  $(".reference-sections #unselect-all-reference-sections").click (event) ->
    event.preventDefault()
    $(".reference-sections input:checkbox").prop('checked', false)
