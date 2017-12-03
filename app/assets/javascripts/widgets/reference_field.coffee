# TODO not use, will be removed.

class AntCat.ReferenceField extends AntCat.ReferencePicker
  constructor: (@parent_element, @options = {}) ->
    @options.click_on_display = true
    @value_id = @options.value_id
    super

  ok: =>
    @set_value @id
    @set_display_text()
    super

  set_value: (value) =>
    $value_field = $('#' + @value_id)
    $value_field.val value

  set_display_text: =>
    reference_text = @current_reference().find('.display').text()
    @display_section.find('.display_button').text reference_text

  load: (url = '') =>
    if url.indexOf('/reference_field') is -1
      url = '/reference_field?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        $element = @parent_element.find('> .antcat_reference_field')
        @initialize $element
        @show_form()
      error: (xhr) => debugger
