class AntCat.TagTypeSelector extends AntCat.NestedForm
  initialize: (@element, @options = {}) ->
    @options.button_container = @element.find('.buttons')
    super

  open: =>
    super
    @element.show()

  close: =>
    super
    @element.hide()

  submit: =>
    @close()
    @options.on_submit() if @options.on_submit

  cancel: =>
    @close()
    @options.on_cancel() if @options.on_cancel

