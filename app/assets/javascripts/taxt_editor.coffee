# TODO: Improve. This and the code in the views is really bad, but that's OK.

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

window.setupTaxtEditors = ->
  unbindAllButtons()

  setupEditButtons()
  setupSaveHistoryItemButtons()
  setupSaveReferenceSectionButtons()
  setupOkButtons()
  setupDeleteButton()
  setupCancelButtons()

unbindAllButtons = ->
  $(
    EDIT_BUTTONS
    CANCEL_BUTTONS
    OK_BUTTONS
    DELETE_BUTTONS
    HISTORY_ITEM_SAVE_BUTTONS
    REFERENCE_SECTION_SAVE_BUTTONS
  ).unbind('click')

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
        AntCat.makeReferenceKeeysExpandable taxtEditor
        taxtEditor.find(TAXT_EDITOR_EDITOR).hide()
        taxtEditor.find(TAXT_PRESENTER).show()
      error: -> alert 'error :('

setupSaveHistoryItemButtons = ->
  $(HISTORY_ITEM_SAVE_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()

    data =
      taxon_history_item:
        taxt:       taxtEditor.find('textarea#taxt').val()
      edit_summary: taxtEditor.find('#edit_summary').val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          taxtEditor.html response.content
          AntCat.makeReferenceKeeysExpandable taxtEditor
          AntCat.makeAllPreviewable()
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
      edit_summary:      taxtEditor.find('#edit_summary').val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'PUT'
      dataType: 'json'
      data: data
      success: (response) ->
        if response.error
          alert "Error: #{response.error}"
        else
          taxtEditor.html response.content
          AntCat.makeReferenceKeeysExpandable taxtEditor
          AntCat.makeAllPreviewable()
          window.setupTaxtEditors()
      error: ->
        alert 'error :('

setupDeleteButton = ->
  $(DELETE_BUTTONS).click (event) ->
    event.preventDefault()
    return false unless confirm 'Are you sure?'

    taxtEditor = $(this).parent().parent()

    data =
      edit_summary: taxtEditor.find('#edit_summary').val()

    $.ajax
      url: taxtEditor.data('url')
      type: 'DELETE'
      dataType: 'json'
      data: data
      success: -> taxtEditor.remove()
      error: -> alert 'error :('

setupCancelButtons = ->
  $(CANCEL_BUTTONS).click (event) ->
    event.preventDefault()

    taxtEditor = $(this).parent().parent()
    taxtEditor.find(TAXT_EDITOR_EDITOR).hide()
    taxtEditor.find(TAXT_PRESENTER).show()
