# This and the code in the views is really bad, but that's OK.

$ ->
  window.setupTaxtEditors()

EDIT_BUTTONS                    = '.taxt-editor-edit-button'

TAXT_EDITOR_EDITOR              = '.taxt-editor-editor'
TAXT_PRESENTER                  = '.taxt-presenter'

EDIT_SUMMARY_FIELD              = '.edit-summary-js-hook'

window.setupTaxtEditors = ->
  unbindAllButtons()

  setupEditButtons()

  document.body.setAttribute('data-test-taxt-editors-loaded', "true") # HACK.

unbindAllButtons = ->
  $(EDIT_BUTTONS).unbind('click')

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
