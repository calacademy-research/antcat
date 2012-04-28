class AntCat.TaxonForm extends AntCat.Form

  constructor: ->
    super
    new AntCat.ReferencePicker @element.find('.reference_picker'), null, null, true
    @open()

  open: =>
    @element.closest('.taxon_form').show()
    super

  close: =>
    @element.closest('.taxon_form').hide()
    super

  cancel: =>
    @close()
    super

  submit: =>
    @start_spinning()
    @element.ajaxSubmit
      success: @update
      error: @handle_error
      dataType: 'json'
    false

  update: (data, statusText, xhr, $form) =>
    if data.success
      location.reload true
      return
    new_content = $(data.content)
    @element.closest('.taxon_form').replaceWith new_content
    @initialize new_content.find 'form'
    @open()
