class AntCat.TaxonForm extends AntCat.NestedForm

  constructor: ->
    super
    new AntCat.NamePicker $('#taxon_name_picker'), field: true

  open: =>
    @element.closest('.taxon_form').show 'slidedown'
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
      success: @handle_response
      error: @handle_error
      dataType: 'json'
    false

  handle_response: (data, statusText, xhr, $form) =>
    if data.success
      location.reload true
      return
    new_content = $(data.content)
    @element.closest('.taxon_form').replaceWith new_content
    @initialize new_content.find 'form'
    @open()
