# This and the code in the views is really bad, but that's OK.

$ ->
  window.setupTaxtEditors()

EDIT_BUTTONS                    = '.taxt-editor-edit-button'
CANCEL_BUTTONS                  = '.taxt-editor-cancel-button'
HISTORY_ITEM_SAVE_BUTTONS       = '.taxt-editor-history-item-save-button'
REFERENCE_SECTION_SAVE_BUTTONS  = '.taxt-editor-reference-section-save-button'
OK_BUTTONS                      = '.taxt-editor-ok-button'
DELETE_BUTTONS                  = '.taxt-editor-delete-button'

TAXT_EDITOR_EDITOR              = '.taxt-editor-editor'
TAXT_PRESENTER                  = '.taxt-presenter'
TAXT_EDITOR_CONTENT             = '.taxt-editor-content'

EDIT_SUMMARY_FIELD              = '.edit-summary-js-hook'

window.setupTaxtEditors = ->
  unbindAllButtons()

  setupEditButtons()
  setupSaveHistoryItemButtons()
  setupSaveReferenceSectionButtons()
  setupOkButtons()
  setupDeleteButton()
  setupCancelButtons()

unbindAllButtons = ->
  $(EDIT_BUTTONS).unbind('click')
  $(HISTORY_ITEM_SAVE_BUTTONS).unbind('click')
  $(REFERENCE_SECTION_SAVE_BUTTONS).unbind('click')
  $(OK_BUTTONS).unbind('click')
  $(DELETE_BUTTONS).unbind('click')
  $(CANCEL_BUTTONS).unbind('click')

setupEditButtons = ->
  $(EDIT_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()
    taxtEditor.find(TAXT_EDITOR_EDITOR).show()

    textareas = taxtEditor.find('textarea')

    # Render preview. It was not done when the element was created because
    # it's an expensive-ish AJAX call we wanted to delay since the element
    # was hidden anyways.
    textareas.each -> $(this).renderUnrenderedPreviewableHack()

    # Resize textareas according to content.
    textareas.each (index, element) -> $(element).height $(element)[0].scrollHeight

    taxtEditor.find(TAXT_PRESENTER).hide()

setupOkButtons = ->
  $(OK_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()
    toParse = taxtEditor.find('textarea').val()

    $.ajax
      url: "/markdown/preview"
      type: 'POST'
      dataType: 'html'
      data: text: toParse
      success: (html) ->
        taxtEditor.find(TAXT_EDITOR_CONTENT).html html
        taxtEditor.find(TAXT_EDITOR_EDITOR).hide()

        taxtPresenter = taxtEditor.find(TAXT_PRESENTER)
        taxtPresenter.show()
        window.AntCatVue.askForRecompile(taxtPresenter)

        window.setupTaxtEditors()
      error: -> alert 'error :('

setupSaveHistoryItemButtons = ->
  $(HISTORY_ITEM_SAVE_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()

    data =
      history_item:
        taxt: taxtEditor.find('textarea#taxt').val()
        subtype: taxtEditor.find('select[name=subtype]').val()
        picked_value: taxtEditor.find('select[name=picked_value]').val()
        text_value: taxtEditor.find('input[name=text_value]').val()
        object_protonym_id: taxtEditor.find('[name=object_protonym_id]').val()
        object_taxon_id: taxtEditor.find('[name=object_taxon_id]').val()
        reference_id: taxtEditor.find('[name=reference_id]').val()
        pages: taxtEditor.find('input[name=pages]').val()
      taxt_editor_template: taxtEditor.data('taxt-editor-template')
      edit_summary: taxtEditor.find(EDIT_SUMMARY_FIELD).val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          AntCat.notifySuccess("Updated history item")

          parent = taxtEditor.parent()
          parent.html response.content
          window.AntCatVue.askForRecompile(parent)
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
        title_taxt:      taxtEditor.find('textarea#title_taxt').val()
        subtitle_taxt:   taxtEditor.find('textarea#subtitle_taxt').val()
        references_taxt: taxtEditor.find('textarea#references_taxt').val()
      edit_summary:      taxtEditor.find(EDIT_SUMMARY_FIELD).val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          AntCat.notifySuccess("Updated reference section")

          parent = taxtEditor.parent()
          parent.html response.content
          window.AntCatVue.askForRecompile(parent)
          window.setupLinkables()
          window.setupTaxtEditors()
      error: ->
        alert 'error :('

setupDeleteButton = ->
  $(DELETE_BUTTONS).click (event) ->
    event.preventDefault()
    return false unless confirm 'Are you sure?'

    taxtEditor = $(this).parent().parent()

    data =
      edit_summary: taxtEditor.find(EDIT_SUMMARY_FIELD).val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'DELETE'
      dataType: 'json'
      data: data
      success: ->
        AntCat.notifySuccess("Deleted item")

        taxtEditor.parent().remove()
      error: -> alert 'error :('

setupCancelButtons = ->
  $(CANCEL_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()
    taxtEditor.find(TAXT_EDITOR_EDITOR).hide()
    taxtEditor.find(TAXT_PRESENTER).show()
