$ -> new AntCat.ReferencePopup $('#popup'),
  on_ok: (taxt) ->
    $('#results').text taxt
  on_cancel: (id) ->
    $('#results').text id
