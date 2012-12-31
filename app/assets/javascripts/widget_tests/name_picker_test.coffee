$ -> new AntCat.NamePicker $('#picker'),
  field: false,
  on_success: (data) ->
    $('#results').text data.id + ' ' + data.taxt
