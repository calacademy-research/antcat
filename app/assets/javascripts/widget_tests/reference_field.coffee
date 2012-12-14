reference_changed = (id) ->
  $('#selected_reference').text id

$ ->
  new AntCat.Form $('#taxon_form'), button_container: '> table td.buttons'
  new AntCat.ReferencePicker $('#authorship_picker > .antcat_reference_picker'), on_change: reference_changed
  new AntCat.ReferencePicker $('#other_authorship_field > .antcat_reference_picker'), on_change: reference_changed
