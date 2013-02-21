$ ->
  form = new AntCat.NestedForm $('.antcat_form'), button_container: '> table td.buttons'
  new AntCat.NameField $('#test_name_field'),
    parent_form: form,
    field: true,
    on_success: (data) ->
      $('#results').text data.id + ' ' + data.taxt
    on_cancel: ->
      id = $('.antcat_name_field #id').val()
      $('#results').text 'Cancelled: ' + id
