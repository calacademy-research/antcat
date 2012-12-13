$ -> new AntCat.TaxonPicker $('#taxon_picker'),
  on_done: (data) ->
    $('#taxt').text data.taxt
