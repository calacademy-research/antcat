$ ->
  window.setupSynonymsSection()

window.setupSynonymsSection = ->
  setupAddNewButtons = ->
    $(".synonyms-add-js").click (event) =>
      parentSection = $(event.target).closest('.synonyms-subsection-js')
      parentSection.find(".synonyms-controls-js").show()
      parentSection.find('#synonym_taxon_id').select2("open")

  setupCancelNewButtons = ->
    $(".cancel-new-synonym-js").click (event) =>
      parentSection = $(event.target).closest('.synonyms-subsection-js')
      parentSection.find(".synonyms-controls-js").hide()

  setupDeleteButtons = ->
    deleteSynonym = (target) =>
      return unless confirm 'Are you sure you want to delete this synonym?'

      taxon_id = _taxonId()
      synonym_id = $(target).data('synonym-id')
      url = "/taxa/#{taxon_id}/synonyms/#{synonym_id}"
      $.post url, { _method: 'delete' }, null, 'json'
      $(target).closest('.synonym-row').remove()

    $(".delete-synonym-js").click (event) => deleteSynonym(event.target)

  setupReverseSynonymyButtons = ->
    reverseSynonymy = (target) =>
      return unless confirm 'Are you sure you want to reverse this synonymy?'

      taxon_id = _taxonId()
      synonym_id = $(target).data('synonym-id')

      $.ajax
        url: "/taxa/#{taxon_id}/synonyms/#{synonym_id}/reverse_synonymy"
        type: 'put'
        dataType: 'json'
        success: (data) => _replaceSynonymsSection data.content
        error: (xhr) => alert xhr.responseText

    $(".reverse-synonym-js").click (event) => reverseSynonymy(event.target)

  setupSaveNewButtons = ->
    saveSynonymy = (target) =>
      taxon_id = _taxonId()
      select = $(target).parent().find('#synonym_taxon_id')
      synonym_taxon_id = select.val()
      junior_or_senior = $(target).data('junior-or-senior')

      $.ajax
        url: "/taxa/#{taxon_id}/synonyms?#{junior_or_senior}=1&synonym_taxon_id=#{synonym_taxon_id}"
        type: 'post'
        dataType: 'json'
        success: (data) => _replaceSynonymsSection data.content
        error: (xhr) => $("#synonyms-error-message").text JSON.parse(xhr.responseText).error_message

    $(".save-new-synonym-js").click (event) => saveSynonymy(event.target)

  _replaceSynonymsSection = (content) ->
    $("#synonyms-section").parent().replaceWith content
    $("select[data-taxon-select]").each -> $(this).taxonSelectify()
    window.setupSynonymsSection()

  _taxonId = -> $("#synonyms-section").data('taxon-id')

  setupAddNewButtons()
  setupCancelNewButtons()
  setupSaveNewButtons()
  setupReverseSynonymyButtons()
  setupDeleteButtons()
