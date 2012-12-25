$ -> new AntCat.NamePicker $('#taxt'),
  field: false,
  on_success: (data) ->
    $('#results').text data.id
