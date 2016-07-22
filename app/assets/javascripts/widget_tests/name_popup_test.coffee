$ ->
  new AntCat.NamePopup $('#popup'),
    field: false,
    on_success: (data) ->
      $('#results').text data.id + ' ' + data.taxt
    on_cancel: ->
      id = $('#popup #id').val()
      $('#results').text 'Cancelled: ' + id
