class AntCat.TaxonForm extends AntCat.Form

  constructor: ->
    super
    @open()

  cancel: =>
  open: =>
    @element.closest('.taxon_form').show()
    super

  close: =>
    @element.closest('.taxon_form').hide()
    super

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

  update: (data, statusText, xhr, $form) =>


