window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: ($container, id, result_handler) ->

    if $('.antcat-reference-picker', $container).length is 0
      $container.append("<div class='antcat-reference-picker'></div>")

    $('.antcat-reference-picker', $container).load '/reference_pickers', q: id, ->
      $('.antcat-reference-picker', $container)
        .find('.icons')
          .hide()
          .end()
        .find('.reference_edit')
          .hide()
          .end()
        .find(':button.close')
          .click ->
            $('.antcat-reference-picker').remove()
            result_handler() if result_handler
            false
