$ -> new AntCat.ReferencePicker $('#picker'),
  field: false,
  on_success: (data) ->
    $('#results').text data.id
  on_cancel: ->
    $('#results').text data.id
