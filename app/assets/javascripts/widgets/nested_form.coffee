window.AntCat or= {}

# <form> elements can't be nested, but they need to be
# for AntCat's UI model, which involved drilling down
# and display inline forms
#
# This code simulates nested forms by 1) assuming there's
# a top-level <form> element somewhere, and 2) creating
# <div class=nested_form> elements for the nested 'forms'

$.fn.nested_form = (options = {}) ->
  this.each -> new AntCat.NestedForm $(this), options

class AntCat.NestedForm extends AntCat.Form

  @css_class = 'nested_form'

  form: =>
    $nested_form = @element.clone()
    @copy_text_area_values $nested_form
    $nested_form.find('.nested_form').remove()
    $form = $('<form/>')
    $form.html $nested_form
    $form.attr 'action', $nested_form.data 'action'
    $form.attr 'method', $nested_form.data 'method'
    $form

  copy_text_area_values: ($target) =>
    # Fix bug in FireFox/jQuery where the value of textareas
    # isn't copied when the textarea is cloned
    $source_textareas = @element.find 'textarea'
    $target_textareas = $target.find 'textarea'
    for i in [0...$source_textareas.length]
      $target_textareas.eq(i).val $source_textareas.eq(i).val()
