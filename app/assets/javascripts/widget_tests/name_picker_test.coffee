$ ->

  new AntCat.NamePicker $('#picker'),
    field: false,
    on_success: (data) ->
      $('#results').text data.id + ' ' + data.taxt
    on_cancel: ->
      id = $('#picker #id').val()
      $('#results').text 'Cancelled: ' + id
