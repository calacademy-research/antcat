reference_changed = (id) ->
  $('#selected_reference').text $('#picker .value').val()

$ ->
  new AntCat.NestedForm $('#taxon_form'), button_container: '> table td.buttons'
  new AntCat.ReferencePicker $('#picker'), on_change: reference_changed
  new AntCat.ReferencePicker $('#other_authorship_field'), on_change: reference_changed
