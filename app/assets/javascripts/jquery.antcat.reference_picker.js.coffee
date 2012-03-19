window.AntCat or= {}

class AntCat.ReferencePicker
  constructor: ($container) ->
    @container = $container
    @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker').load '/reference_pickers', q: '128176',
      @setup_items

  setup_items: ->
    $('.antcat-reference-picker .icons', @container).hide()
    $('.antcat-reference-picker .reference_edit', @container).hide()
