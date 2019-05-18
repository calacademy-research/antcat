# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually, as is the case with textareas for
# posting comment replies (not the main comment box visible by default).
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).

$ ->
  AntCat.makeAllPreviewable()
  makeLoadingSpinnersAvailableForAtJs()

AntCat.makeAllPreviewable = ->
  $("textarea[data-previewable]").each -> $(this).makePreviewable()

$.fn.makePreviewable = -> new MakePreviewable this

# Super dirty.
$.fn.renderUnrenderedPreviewableHack = -> new MakePreviewable this, true

class MakePreviewable
  constructor: (@textarea, justRender = false) ->
    if @isAlreadyPreviewable() and justRender
      return if @textarea.val() == ""
      return @renderPreview()

    return if @isAlreadyPreviewable()

    @wrapInPreviewArea()
    @setupPreviewLink()

    if @textarea.data('use-extras')
      new ExtrasArea(@textarea, @textarea.parent().parent().parent())

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
    <div class="preview-area">
      <div class="row">
        <div class="medium-6 columns">#{title}</div>
        <div class="medium-6 columns">
          Preview
          <button class="btn-nodanger btn-tiny preview-link">Rerender preview</button>
          <a><span class="shared-spinner"><i class="fa fa-refresh fa-spin"></i></span></a>
        </div>
      </div>
      <div class="row">
        <div class="medium-6 columns preview-editable is-already-previewable"></div>
        <div class="medium-6 columns preview-previewable"></div>
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
    if toParse is ""
      tab.html "No content. Try this: <code>{tax 430207}</code>."
      return

    tab.html "Loading preview... dot dot dot..."
    @showSpinner()

    $.ajax
      url: "/markdown/preview"
      type: "post"
      data: text: toParse
      dataType: "html"
      success: (html) =>
        tab.html html
        # Re-trigger to make references expandable.
        AntCat.makeReferenceKeeysExpandable tab
        @hideSpinner() # Only hide on success.
      error: -> tab.text "Error rendering preview"

  spinner: -> @textarea.closest(".preview-area").find ".shared-spinner"
  showSpinner: -> @spinner().show()
  hideSpinner: -> @spinner().hide()

class ExtrasArea
  DEFAULT_REFERENCE_BUTTON_ID        = "default-reference-button"
  RECENTLY_USED_REFERENCES_BUTTON_ID = "recently-used-references-button"
  INSERT_REFERENCE_BUTTON_ID         = "insert-reference-button"
  INSERT_TAXON_BUTTON_ID             = "insert-taxon-button"
  CONVERT_BOLTON_KEYS_BUTTON_ID      = "convert-bolton-keys-button"

  constructor: (@textarea, @textareaTab) ->
    @createExtrasArea().appendTo @textareaTab
    AntCat.renderTooltips() if AntCat.renderTooltips
    @setupDefaultReferenceButton()
    @setupInsertTaxaButtons()
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
        <span id="extras-area"></span>
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

    button.html reference.keey
    button.click =>
      event.preventDefault()
      @textarea.insertAtCaret "{ref #{reference.id}}: "

  setupInsertTaxaButtons: ->
    insertTaxonButton = (id, name) ->
      """<a class="insert-taxon btn-normal btn-tiny" data-id="#{id}">#{name}</a> """

    taxa = $('#taxon-and-ancestors').data('taxa')
    return unless taxa

    taxa.forEach (taxon) =>
      @textareaTab.find('#extras-area').prepend insertTaxonButton(taxon.id, taxon.name)

    @textareaTab.find('.insert-taxon').click (event) =>
      event.preventDefault()
      id = $(event.target).data('id')
      @textarea.insertAtCaret "{tax #{id}} "

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
          previewTab = @textarea.parent().parent().find(".preview-previewable")
          previewTab.html "Converted Bolton keys, click 'Render preview' to preview"
        error: -> $.notify "Error parsing Bolton keys"

defaultReference = ->
  reference = $('#default-reference')
  id = reference.data('id')
  keey = reference.data('keey')

  { id: id, keey: keey }

# Global to make it callable by at.js.
# This may be very *not* performant...
makeLoadingSpinnersAvailableForAtJs = ->
  # `object` is "something" that was passed by at.js.
  findSpinner = (object) ->
    textarea = object.$inputor
    textarea.closest(".preview-area").find ".shared-spinner"

  window.MDPreview =
    showSpinner: (object) -> findSpinner(object).show()
    hideSpinner: (object) -> findSpinner(object).hide()
