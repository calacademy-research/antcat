class AntCat.TagTypeSelector extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    @options.button_container = @element.find('.buttons')
    @options.modal = true
    super

  submit: =>
    @close()
    @options.on_ok()

  cancel: =>
    @close()
