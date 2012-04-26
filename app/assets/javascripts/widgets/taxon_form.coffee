class AntCat.TaxonForm extends AntCat.Form

  constructor: ->
    super
    @element.closest('.taxon_form').show()
    @open()

  cancel: =>
    @element.closest('.taxon_form').hide()
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


