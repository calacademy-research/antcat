# This and the code in the views is really bad, but that's OK.

$ ->
  window.setupTaxtEditors()

EDIT_BUTTONS                    = '.taxt-editor-edit-button'
HISTORY_ITEM_SAVE_BUTTONS       = '.taxt-editor-history-item-save-button'
REFERENCE_SECTION_SAVE_BUTTONS  = '.taxt-editor-reference-section-save-button'

TAXT_EDITOR_EDITOR              = '.taxt-editor-editor'
TAXT_PRESENTER                  = '.taxt-presenter'

EDIT_SUMMARY_FIELD              = '.edit-summary-js-hook'

window.setupTaxtEditors = ->
  unbindAllButtons()

  setupEditButtons()
  setupSaveHistoryItemButtons()
  setupSaveReferenceSectionButtons()

  document.body.setAttribute('data-test-taxt-editors-loaded', "true") # HACK.

unbindAllButtons = ->
  $(EDIT_BUTTONS).unbind('click')
  $(HISTORY_ITEM_SAVE_BUTTONS).unbind('click')
  $(REFERENCE_SECTION_SAVE_BUTTONS).unbind('click')

setupEditButtons = ->
  $(EDIT_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()
    taxtEditor.find(TAXT_EDITOR_EDITOR).get(0).classList.remove("hidden")

    textareas = taxtEditor.find('textarea')

    # Render preview. It was not done when the element was created because
    # it's an expensive-ish AJAX call we wanted to delay since the element
    # was hidden anyways.
    textareas.each -> $(this).renderUnrenderedPreviewableHack()

    # Resize textareas according to content.
    textareas.each (index, element) -> $(element).height $(element)[0].scrollHeight

    taxtEditor.find(TAXT_PRESENTER).get(0).classList.add("hidden")

setupSaveHistoryItemButtons = ->
  $(HISTORY_ITEM_SAVE_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()

    data =
      history_item:
        taxt: taxtEditor.find('textarea#taxt').get(0)?.value
        subtype: taxtEditor.find('select[name=subtype]').get(0)?.value
        picked_value: taxtEditor.find('select[name=picked_value]').get(0)?.value
        text_value: taxtEditor.find('input[name=text_value]').get(0)?.value
        object_protonym_id: taxtEditor.find('[name=object_protonym_id]').get(0)?.value
        object_taxon_id: taxtEditor.find('[name=object_taxon_id]').get(0)?.value
        reference_id: taxtEditor.find('[name=reference_id]').get(0)?.value
        pages: taxtEditor.find('input[name=pages]').get(0)?.value
      edit_summary: taxtEditor.find(EDIT_SUMMARY_FIELD).get(0).value

    $.ajax
      url: taxtEditor.data('taxt-editor-url-value')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          AntCat.notifySuccess("Updated history item")

          taxtEditor.get(0).parentNode.innerHTML = response.content
          window.setupLinkables()
          window.setupTaxtEditors()
      error: ->
        alert 'error :('

setupSaveReferenceSectionButtons = ->
  $(REFERENCE_SECTION_SAVE_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()

    data =
      reference_section:
        title_taxt:      taxtEditor.find('textarea#title_taxt').get(0).value
        subtitle_taxt:   taxtEditor.find('textarea#subtitle_taxt').get(0).value
        references_taxt: taxtEditor.find('textarea#references_taxt').get(0).value
      edit_summary:      taxtEditor.find(EDIT_SUMMARY_FIELD).get(0).value

    $.ajax
      url: taxtEditor.data('taxt-editor-url-value')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          AntCat.notifySuccess("Updated reference section")

          taxtEditor.get(0).parentNode.innerHTML = response.content
          window.setupLinkables()
          window.setupTaxtEditors()
      error: ->
        alert 'error :('
