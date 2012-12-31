$ ->
  new AntCat.NestedForm $('#taxon_form'), button_container: '> table td.buttons'
  new AntCat.NamePicker $('#picker'),
    field: true,
    on_success: (data) ->
      $('#results').text(data.id) + ' ' + data.taxt
