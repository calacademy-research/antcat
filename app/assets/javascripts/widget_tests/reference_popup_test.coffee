$ -> new AntCat.ReferencePopup $('#popup'),
  field: false,
  on_ok: (data) ->
    $('#results').text data.id
  on_cancel: (id) ->
    $('#results').text id
