window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (@container, @id, @result_handler) ->
    if $('.antcat-reference-picker', @container).length is 0
      @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker', @container).load '/reference_pickers', id: @id, @setup_picker

  setup_picker: =>
    $('.antcat-reference-picker')
      .find(':button.close', @container)
        .click =>
          $('.antcat-reference-picker').remove()
          @result_handler() if @result_handler
          false
        .end()
      .find('form', @container)
        .submit =>
          @get_search_results()
          false
        .end()
    $('.antcat-reference-picker')
      .show()
      .find('input[type=text]')
        .focus()

  get_search_results: =>
    if $('.antcat-reference-picker', @container).length is 0
      @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker', @container).load '/reference_pickers', q: @container.find('#q').val(), @setup_picker
