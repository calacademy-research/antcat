class AntCat.ReferencePopup extends AntCat.ReferencePicker
  _post_constructor: (@element, @options) =>
    AntCat.check 'ReferencePopup._post_constructor', '@element', @element
    if @options.id
      @id = @options.id
    else
      @id = @element.find('#reference_picker_id').val()

    @original_id = @id
    if @id
      @load ''
    else
      @initialize()

  load: (url = '') =>
    if url.indexOf('/reference_popup') is -1
      url = '/reference_popup?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find('> .antcat_reference_popup')
        @initialize()
      error: (xhr) => debugger

  initialize: =>
    @setup_cached_elements()
    @setup_controls()
    @setup_references()
    @handle_new_selection()
    @show()
    @textbox.focus()

  editing: => @element.find('.edit:visible .nested_form').length > 0

  show: =>
    @element.show()
    @edit_section.show()
    @expansion.show()

  ok: =>
    @element.find('#reference_picker_id').val(@id)
    taxt = if @current_reference() then @current_reference().data 'taxt' else null
    @options.on_ok(taxt) if @options.on_ok
    @close()

  cancel: =>
    @clear_current()
    @id = @original_id
    @element.find('#reference_picker_id').val(@id)
    @options.on_cancel(@id) if @options.on_cancel
    @close()

  close: =>
    @element.hide()
    @options.on_close() if @options.on_close

  value: => @id
