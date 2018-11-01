# <form> elements can't be nested, but they need to be
# for AntCat's UI model, which involves drilling down
# and displaying inline forms
#
# This code simulates nested forms by converting
# <div class=nested_form> elements to <form>s
class AntCat.NestedForm extends AntCat.AjaxForm
  form: =>
    AntCat.NestedForm.create_form_from @element

  @create_form_from: ($source) ->
    $target_form = $source.clone()
    AntCat.NestedForm.copy_text_area_values $source, $target_form
    $target_form.find('.nested_form').remove()
    $form = $('<form/>')
    $form.html $target_form
    $form.attr 'action', $source.data 'action'
    $form.attr 'method', $source.data 'method'
    $form

  @copy_text_area_values: ($source, $target) ->
    # Fix bug in FireFox/jQuery where the value of textareas
    # isn't copied when the textarea is cloned
    $source_textareas = $source.find 'textarea'
    $target_textareas = $target.find 'textarea'
    for i in [0...$source_textareas.length]
      $target_textareas.eq(i).val $source_textareas.eq(i).val()
