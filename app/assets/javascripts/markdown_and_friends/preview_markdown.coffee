# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually in case the previewable is not visible on page load.
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).

$ ->
  AntCat.makeAllPreviewable()

AntCat.makeAllPreviewable = ->
  $("textarea[data-previewable]").each -> $(this).makePreviewable()

$.fn.makePreviewable = -> new MakePreviewable this

# Super dirty.
$.fn.renderUnrenderedPreviewableHack = -> new MakePreviewable(this, true)

class MakePreviewable
  constructor: (@textarea, justRender = false) ->
    if @isAlreadyPreviewable() and justRender
      return if @textarea.get(0).value == ""
      return @renderPreview()

    return if @isAlreadyPreviewable()

    @wrapInPreviewArea()
    @setupPreviewLink()

    if @textarea.get(0).getAttribute('data-use-extras')
      new ExtrasArea(@textarea, @textarea.parent().parent().parent(), this)

    @renderPreview() if @textarea.is(":visible") and @textarea.get(0).value != ""

    # Resize textareas according to content (works only for visible text areas).
    @textarea.get(0).style.height = "#{@textarea[0].scrollHeight}px"

  isAlreadyPreviewable: -> @textarea.get(0).parentNode.classList.contains("is-already-previewable")

  wrapInPreviewArea: ->
    # Create new preview area (tabs) and insert after textarea, and tabify.
    title = @textarea.get(0).getAttribute('data-previewable-title') || "Text"
    previewArea = @createPreviewArea title
    previewArea.insertAfter @textarea

    # Move textarea inside the first tab of the preview area.
    @textarea.detach().prependTo previewArea.find(".preview-editable")

  createPreviewArea: (title) ->
    $ """
    <div class="preview-area mb-4">
      <div class="grid grid-cols-2 gap-4">
        <div>#{title}</div>
        <div>
          Preview
          <button class="btn-neutral preview-link">Rerender preview</button>
        </div>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div class="preview-editable is-already-previewable [&_textarea]:text-lg"></div>
        <div class="preview-previewable p-2 border border-gray-300 min-h-[4rem]"></div>
      </div>
    </div>
    """

  setupPreviewLink: ->
    @textarea.parent().parent().parent().find(".preview-link").click (event) =>
      event.preventDefault()
      @renderPreview()

  renderPreview: ->
    tab = @textarea.parent().parent().find(".preview-previewable")

    toParse = @textarea.get(0).value
    formatTypeFields = @textarea.get(0).getAttribute('data-format-type-fields')

    if toParse is ""
      tab.get(0).innerHTML = "No content. Try this: <code>{tax 430207}</code>"
      return

    $.ajax
      url: "/markdown/preview"
      type: "POST"
      data:
        text: toParse
        format_type_fields: formatTypeFields
      dataType: "html"
      success: (html) =>
        tab.get(0).innerHTML = html
        window.setupLinkables()
      error: -> tab.get(0).textContent = "Error rendering preview"

class ExtrasArea
  DEFAULT_REFERENCE_BUTTON_ID        = "default-reference-button"
  RECENTLY_USED_REFERENCES_BUTTON_ID = "recently-used-references-button"
  INSERT_REFERENCE_BUTTON_ID         = "insert-reference-button"
  INSERT_TAXON_BUTTON_ID             = "insert-taxon-button"
  CONVERT_BOLTON_KEYS_BUTTON_ID      = "convert-bolton-keys-button"

  constructor: (@textarea, @textareaTab, @taxtEditor) ->
    @createExtrasArea().appendTo @textareaTab
    @setupDefaultReferenceButton()
    @setupRecentlyUserReferencesButton()
    @setupInsertReferenceButton()
    @setupInsertTaxonButton()

    @setupConvertBoltonKeysButton()

  createExtrasArea: ->
    $ """
    <div class="grid grid-cols-2 gap-4">
      <div class="leading-7">
        <button id="#{DEFAULT_REFERENCE_BUTTON_ID}" class="btn-default">Default reference</button>
        <button id="#{RECENTLY_USED_REFERENCES_BUTTON_ID}" class="btn-default">Recently used references</button>
        <button id="#{INSERT_REFERENCE_BUTTON_ID}" class="btn-default">+Reference</button>
        <button id="#{INSERT_TAXON_BUTTON_ID}" class="btn-default">+Taxon</button>
        <button id="#{CONVERT_BOLTON_KEYS_BUTTON_ID}" class="btn-danger">Convert Bolton keys</button>
      </div>
    </div>
    """

  setupRecentlyUserReferencesButton: ->
    button = @textareaTab.find("##{RECENTLY_USED_REFERENCES_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.get(0).value

      @_insertAtCaret(@textarea, "!!")
      afterValue = @textarea.get(0).value

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  setupInsertReferenceButton: ->
    button = @textareaTab.find("##{INSERT_REFERENCE_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.get(0).value

      selectedValue = AntCat.getInputSelection(@textarea.get(0))
      @_insertAtCaret(@textarea, "{r#{selectedValue}")
      afterValue = @textarea.get(0).value

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  setupInsertTaxonButton: ->
    button = @textareaTab.find("##{INSERT_TAXON_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.get(0).value

      selectedValue = AntCat.getInputSelection(@textarea.get(0))
      @_insertAtCaret(@textarea, "{t#{selectedValue}")
      afterValue = @textarea.get(0).value

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  restoreIfUnchanged: (originalValue, afterValue) ->
    @textarea.off 'hidden.atwho'
    @textarea.on 'hidden.atwho', =>
      if @textarea.get(0).value == afterValue
        @textarea.get(0).value = originalValue

  setupDefaultReferenceButton: ->
    reference = defaultReference()
    button = @textareaTab.find("##{DEFAULT_REFERENCE_BUTTON_ID}")

    unless reference?.id
      button.get(0).setAttribute("disabled", "disabled")
      return

    button.get(0).innerHTML = reference.referenceKey
    button.click =>
      event.preventDefault()
      @_insertAtCaret(@textarea, "{ref #{reference.id}}: ")

  setupConvertBoltonKeysButton: ->
    button = @textareaTab.find("##{CONVERT_BOLTON_KEYS_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      $.ajax
        url: "/panel/bolton_keys_to_ref_tags.json"
        type: "POST"
        data: bolton_content: @textarea.get(0).value
        dataType: "html"
        success: (parsedContent) =>
          @textarea.get(0).value = parsedContent
          @taxtEditor.renderPreview()
          AntCat.notifySuccess "Converted Bolton keys"
        error: -> AntCat.notifyError "Error parsing Bolton keys"

  # Via https://stackoverflow.com/questions/28873350
  _insertAtCaret: (jQueryElement, valueToInsert) ->
    element = jQueryElement.first().get(0)

    if document.selection # For browsers like Internet Explorer.
      element.focus()
      selection = document.selection.createRange()
      selection.text = valueToInsert
      element.focus()
    else if element.selectionStart || element.selectionStart == '0' || element.selectionStart == 0 # Firefox and Webkit-based.
      startPos = element.selectionStart
      endPos = element.selectionEnd
      scrollTop = element.scrollTop
      element.value = element.value.substring(0, startPos) + valueToInsert + element.value.substring(endPos, element.value.length)
      element.focus()
      element.selectionStart = startPos + valueToInsert.length
      element.selectionEnd = startPos + valueToInsert.length
      element.scrollTop = scrollTop
    else
      element.value += valueToInsert
      element.focus()

defaultReference = ->
  reference = $('#default-reference').get(0)
  id = reference.getAttribute('data-reference-id')
  referenceKey = reference.getAttribute('data-reference-key')

  { id: id, referenceKey: referenceKey }
