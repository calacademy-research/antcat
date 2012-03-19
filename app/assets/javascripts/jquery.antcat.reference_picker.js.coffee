window.AntCat or= {}

class AntCat.ReferencePicker
  constructor: ($container) ->
    $container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker').load '/reference_pickers', q: '128176'
