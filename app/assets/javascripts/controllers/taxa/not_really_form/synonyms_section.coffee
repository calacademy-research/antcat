class AntCat.SynonymsSection
  constructor: (@element, @options = {}) ->
    @parent_form = @options.parent_form
    @initialize()

  initialize: =>
    @setup_add_buttons()
    @setup_delete_buttons()
    @setup_reverse_synonymy_buttons()
    @taxonSelectify()

  taxonSelectify: -> $('#synonym_taxon_id').taxonSelectify()

  setup_add_buttons: =>
    $add_button = @element.find 'button.add'
    $add_button.click => @add(); false

  setup_delete_buttons: =>
    $delete_buttons = @element.find 'button.delete'
    $delete_buttons.show() if AntCat.testing
    $delete_buttons.click (event) => @delete(event.target); false
    @element.find('.synonym_row').hover(
      (event) =>
        $(event.target).closest('.synonym_row')
          .select().find('.delete').show().end()
      (event) =>
        AntCat.deselect()
        $delete_buttons.hide()
    )

  setup_reverse_synonymy_buttons: =>
    $reverse_synonymy_buttons = @element.find 'button.reverse_synonymy'
    $reverse_synonymy_buttons.show() if AntCat.testing
    $reverse_synonymy_buttons.click (event) => @reverse_synonymy(event.target); false
    @element.find('.synonym_row').hover(
      (event) =>
        $(event.target).closest('.synonym_row')
          .select().find('.reverse_synonymy').show().end()
      (event) =>
        AntCat.deselect()
        $reverse_synonymy_buttons.hide()
    )

  add: =>
    form = new AntCat.SynonymsSectionForm @element.find('.synonym-form'),
      on_open: @on_form_open, on_close: @on_form_close, on_success: @handle_success
    form.open()

  handle_success: (data) =>
    @parent_form.replace_junior_and_senior_synonyms_section data.content
    @initialize()

  delete: (target) =>
    return unless @confirm target, 'Are you sure you want to delete this synonym?'
    taxon_id = $(target).data('taxon-id')
    synonym_id = $(target).data('synonym-id')
    url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}"
    $.post url, {_method: 'delete'}, null, 'json'
    $(target).closest('.synonym_row').remove()

  reverse_synonymy: (target) =>
    return unless @confirm target, 'Are you sure you want to reverse this synonymy?'
    taxon_id = $(target).data('taxon-id')
    synonym_id = $(target).data('synonym-id')
    url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}/reverse_synonymy"
    $.ajax
      url: url
      type: 'put'
      dataType: 'json'
      success: (data) =>
        @parent_form.replace_junior_and_senior_synonyms_section data.content
      error: (xhr) => debugger

  confirm: (button, question) =>
    $row = $(button).closest '.synonym_row'
    $row.addClass 'confirming'
    result = confirm question
    $row.removeClass 'confirming'
    result

  on_form_open: =>
    @taxonSelectify()
    @element.find('#synonym_taxon_id').select2('open')

  on_form_close: =>
    @element.find('#synonym_taxon_id').select2('destroy')
    @element.find('#synonym_taxon_id').val('')

class AntCat.SynonymsSectionForm extends AntCat.NestedForm
  constructor: ->
    super
    @select = @element.find('#synonym_taxon_id')
    @error_message = @element.find('#error_message')

  submit: =>
    return false if @select.val().length == 0
    @error_message.text ''
    super

  handle_application_error: (data) =>
    super
    @error_message.text data.error_message
