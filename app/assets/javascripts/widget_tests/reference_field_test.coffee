$ ->
  form = new AntCat.NestedForm $('#taxon_form'), button_container: '> table > tbody > tr.buttons > td.buttons'
  new AntCat.ReferenceField $('#authorship_field'), value_id: 'authorship_value', parent_form: form
