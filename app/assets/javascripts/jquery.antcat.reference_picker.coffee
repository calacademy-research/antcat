window.AntCat or= {}

class AntCat.ReferencePicker

  constructor: (@container, @id, @result_handler) ->
    if @container.find('.antcat-reference-picker').length is 0
      @container.append("<div class='antcat-reference-picker'></div>")
    @container.find('.antcat-reference-picker').load '/reference_pickers', id: @id, @setup_picker
    @

  setup_picker: =>
    @container.find('.antcat-reference-picker')

      .find(':button, :submit')
        .button()
        .end()

      .find(':button.close, :button.ok')
        .click =>
          @close()
          false
        .end()

      .find('form')
        .keypress (event) =>
          return true unless event.which is @ENTER
          @get_search_results()
          false

        .submit =>
          @get_search_results()
          false
        .end()

      .find('.references')
        .selectable(filter: '.reference', stop: @enable_or_disable_ok_button)
        .end()

      .find("#reference_#{@id}")
        .addClass('ui-selected')
        .end()

      .show()

      .find('#q')
        .focus()

      reference_picker_setupAuthorAutocomplete @container.find('.antcat-reference-picker #q')

      @enable_or_disable_ok_button()

  enable_or_disable_ok_button: =>
    ok_button = @container.find '.antcat-reference-picker :button.ok'
    if @container.find('.antcat-reference-picker .ui-selected').length is 0
      ok_button.attr 'disabled', 'disabled'
    else
      ok_button.removeAttr 'disabled'

  get_search_results: =>
    @container.find('.antcat-reference-picker')
      .load '/reference_pickers',
            q: @container.find('.antcat-reference-picker #q').val(),
            search_selector: @container.find('.antcat-reference-picker #search_selector').val(),
            @setup_picker

  close: =>
    @container.find('.antcat-reference-picker').remove()
    @result_handler() if @result_handler

  ENTER: 13

