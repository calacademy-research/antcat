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
      return if @textarea.val() == ""
      return @renderPreview()

    return if @isAlreadyPreviewable()

    @wrapInPreviewArea()
    @setupPreviewLink()

    if @textarea.data('use-extras')
      new ExtrasArea(@textarea, @textarea.parent().parent().parent(), this)

    @renderPreview() if @textarea.is(":visible") and @textarea.val() != ""

    # Resize textareas according to content (works only for visible text areas).
    @textarea.height @textarea[0].scrollHeight

  isAlreadyPreviewable: -> @textarea.parent().hasClass "is-already-previewable"

  wrapInPreviewArea: ->
    # Create new preview area (tabs) and insert after textarea, and tabify.
    title = @textarea.data("previewable-title") || "Text"
    previewArea = @createPreviewArea title
    previewArea.insertAfter @textarea

    # Move textarea inside the first tab of the preview area.
    @textarea.detach().prependTo previewArea.find(".preview-editable")

  createPreviewArea: (title) ->
    $ """
    <div class="preview-area mb-4">
      <div class="row">
        <div class="medium-6 columns">#{title}</div>
        <div class="medium-6 columns">
          Preview
          <button class="btn-nodanger btn-tiny preview-link">Rerender preview</button>
        </div>
      </div>
      <div class="row">
        <div class="medium-6 columns preview-editable is-already-previewable"></div>
        <div class="medium-6 columns preview-previewable p-2 border border-solid border-medium-gray"></div>
      </div>
    </div>
    """

  setupPreviewLink: ->
    @textarea.parent().parent().parent().find(".preview-link").click (event) =>
      event.preventDefault()
      @renderPreview()

  renderPreview: ->
    tab = @textarea.parent().parent().find(".preview-previewable")

    toParse = @textarea.val()
    formatTypeFields = @textarea.data('format-type-fields')

    if toParse is ""
      tab.html "No content. Try this: <code>{tax 430207}</code>."
      return

    $.ajax
      url: "/markdown/preview"
      type: "post"
      data:
        text: toParse
        format_type_fields: formatTypeFields
      dataType: "html"
      success: (html) =>
        tab.html html
        window.setupLinkables()
        if typeof variable != 'undefined'
          window.setupTaxtEditors()
      error: -> tab.text "Error rendering preview"

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
    <div class="row">
      <div class="medium-6 columns end">
        <a id="#{DEFAULT_REFERENCE_BUTTON_ID}" class="btn-normal btn-tiny">Default reference</a>
        <a id="#{RECENTLY_USED_REFERENCES_BUTTON_ID}" class="btn-normal btn-tiny">Recently used references</a>
        <a id="#{INSERT_REFERENCE_BUTTON_ID}" class="btn-normal btn-tiny">+Reference</a>
        <a id="#{INSERT_TAXON_BUTTON_ID}" class="btn-normal btn-tiny">+Taxon</a>
        <a id="#{CONVERT_BOLTON_KEYS_BUTTON_ID}" class="btn-warning btn-tiny">Convert Bolton keys</a>
      </div>
    </div>
    """

  setupRecentlyUserReferencesButton: ->
    button = @textareaTab.find("##{RECENTLY_USED_REFERENCES_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.val()

      @textarea.insertAtCaret "!!"
      afterValue = @textarea.val()

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  setupInsertReferenceButton: ->
    button = @textareaTab.find("##{INSERT_REFERENCE_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.val()

      selectedValue = AntCat.getInputSelection(@textarea.get(0))
      @textarea.insertAtCaret "{r#{selectedValue}"
      afterValue = @textarea.val()

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  setupInsertTaxonButton: ->
    button = @textareaTab.find("##{INSERT_TAXON_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      originalValue = @textarea.val()

      selectedValue = AntCat.getInputSelection(@textarea.get(0))
      @textarea.insertAtCaret "{t#{selectedValue}"
      afterValue = @textarea.val()

      @restoreIfUnchanged originalValue, afterValue
      @textarea.trigger('click.atwhoInner')

  restoreIfUnchanged: (originalValue, afterValue) ->
    @textarea.off 'hidden.atwho'
    @textarea.on 'hidden.atwho', =>
      if @textarea.val() == afterValue
        @textarea.val originalValue

  setupDefaultReferenceButton: ->
    reference = defaultReference()
    button = @textareaTab.find("##{DEFAULT_REFERENCE_BUTTON_ID}")

    unless reference?.id
      button.addClass('ui-state-disabled')
      return

    button.html reference.referenceKey
    button.click =>
      event.preventDefault()
      @textarea.insertAtCaret "{ref #{reference.id}}: "

  setupConvertBoltonKeysButton: ->
    button = @textareaTab.find("##{CONVERT_BOLTON_KEYS_BUTTON_ID}")

    button.click =>
      event.preventDefault()

      $.ajax
        url: "/panel/bolton_keys_to_ref_tags.json"
        type: "post"
        data: bolton_content: @textarea.val()
        dataType: "html"
        success: (parsedContent) =>
          @textarea.val parsedContent
          @taxtEditor.renderPreview()
          AntCat.notifySuccess "Converted Bolton keys"
        error: -> AntCat.notifyError "Error parsing Bolton keys"

defaultReference = ->
  reference = $('#default-reference')
  id = reference.data('id')
  referenceKey = reference.data('reference-key')

  { id: id, referenceKey: referenceKey }
