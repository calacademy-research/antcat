window.AntCat or= {}

class AntCat.ReferencePicker
  constructor: ($container, id, result_handler) ->
    @container = $container
    @id = id
    @result_handler = result_handler
    @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker').load '/reference_pickers', q: @id, @setup_items

  setup_items: =>
    $('.antcat-reference-picker .icons', @container).hide()
    $('.antcat-reference-picker .reference_edit', @container).hide()
    $('.antcat-reference-picker :button.close', @container).click @close_picker

  close_picker: =>
    $('.antcat-reference-picker').remove()
    @result_handler()
    false
