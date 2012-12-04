$.fn.reference_panel = (options = {}) ->
  this.each -> new AntCat.ReferencePanel $(this), options

class AntCat.ReferencePanel extends AntCat.Panel
  constructor: ->
    super
    @edit() if @options.edit

  element_class: 'reference'
  @element_class: 'reference'
  create_form: ($element, options) => new AntCat.ReferenceForm $element, options

  on_form_open: => @options.on_form_open()
  on_form_close: => @options.on_form_close()
  on_form_done: (data) => @options.on_form_done $(data.content)

  form: =>
    @_form or= @create_form @element.find('.nested_form'),
      on_open: @on_form_open
      on_close: @on_form_close
      on_update: @on_form_update
      on_done: @on_form_done
      on_cancel: @on_form_cancel
