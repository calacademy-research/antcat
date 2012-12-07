class AntCat.TagTypeSelector extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    @options.button_container = @element.find('.buttons')
    @options.modal = true
    @element.find('.buttons :button').unbutton().button()
    super

  # returns taxon_button or reference_button
  submit: (eventObject) =>
    @close()
    @options.on_ok($(eventObject.currentTarget).attr('id'))

  cancel: =>
    @close()
