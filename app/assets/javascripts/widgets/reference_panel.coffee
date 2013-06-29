$.fn.reference_panel = (options = {}) ->
  this.each -> new AntCat.ReferencePanel $(this), options

class AntCat.ReferencePanel extends AntCat.Panel
  constructor: (@element, @options = {}) ->
    @options.click_on_icon = true
    super
    @edit() if @options.edit

  create_form: ($element, options) =>
    AntCat.check 'ReferencePanel.create_form', '$element', $element
    new AntCat.ReferenceForm $element, options

  on_form_open:        => @options.on_form_open()
  on_form_close:       => @options.on_form_close()
  on_form_done: (data) => @options.on_form_done $(data.content)

  form: =>
    @_form or= @create_form @element.find('.nested_form'),
      on_open:     @on_form_open
      on_close:    @on_form_close
      on_response: @on_form_response
      on_success:  @on_form_success
      on_cancel:   @on_form_cancel
