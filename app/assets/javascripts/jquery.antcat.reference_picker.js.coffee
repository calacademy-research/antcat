window.AntCat or= {}

class AntCat.ReferencePicker
  constructor: ($container, id, result_handler) ->
    @container = $container
    @id = id
    @result_handler = result_handler
    $('.antcat-reference-picker', @container).remove()
    @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker').load '/reference_pickers', q: @id, @setup_items

  setup_items: =>
    $('.antcat-reference-picker', @container)
      .find('.icons')
        .hide()
        .end()
      .find('.reference_edit')
        .hide()
        .end()
      .find(':button.close')
        .click @close_picker

  close_picker: =>
    $('.antcat-reference-picker').remove()
    @result_handler() if @result_handler
    false
