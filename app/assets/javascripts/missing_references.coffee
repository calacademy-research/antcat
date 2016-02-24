$ ->
  # reference picker code from widget_tests/reference_field_test
  # the form is not really used, just for adding the ReferenceField
  form = new AntCat.NestedForm $('.edit_missing_reference')

  new AntCat.ReferenceField $('#replacement_id_field'),
    value_id: 'replacement_id', parent_form: form
