window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (@container, @id, @result_handler) ->
    if $('.antcat-reference-picker', @container).length is 0
      @container.append("<div class='antcat-reference-picker'></div>")
    $('.antcat-reference-picker', @container).load '/reference_pickers', id: @id, =>
      @setup_picker()
    @

  setup_picker: =>
    $('.antcat-reference-picker')

      .find(':button.ok', @container)
        .click =>
          $('.antcat-reference-picker').remove()
          @result_handler() if @result_handler
          false
        .end()

      .find(':button,:submit')
        .button()
        .end()

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

      .find('.references')
        .selectable(
          filter: '.reference'
          stop: @enable_or_disable_ok_button)
        .end()

      .find("#reference_#{@id}")
        .addClass('ui-selected')
        .end()

      .show()
      .find('#q')
        .focus()

      @enable_or_disable_ok_button()

  enable_or_disable_ok_button: =>
    ok_button = @container.find ':button.ok'
    if $('.ui-selected').length is 0
      ok_button.attr 'disabled', 'disabled'
    else
      ok_button.removeAttr 'disabled'

  get_search_results: =>
    $('.antcat-reference-picker', @container).load '/reference_pickers', q: @container.find('#q').val(), @setup_picker
