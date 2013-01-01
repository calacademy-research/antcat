$ ->
  new AntCat.NestedForm $('#taxon_form'), button_container: '> table td.buttons'
  new AntCat.NamePicker $('#picker'),
    field: true,
    on_success: (data) ->
      $('#results').text data.id + ' ' + data.taxt
    on_cancel: ->
      id = $('#picker #id').val()
      $('#results').text 'Cancelled: ' + id
