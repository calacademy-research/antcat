class AntCat.TaxonForm extends AntCat.Form
  constructor: ->
    super
    @element.show()
    @open()

  cancel: =>
    @element.hide()
    @close()
    super

  submit: =>
    @start_spinning()
    @element.ajaxSubmit
      success: @cancel
      error: @handle_error
      dataType: 'json'
      type: 'POST'
    false

