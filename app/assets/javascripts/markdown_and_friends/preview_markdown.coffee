# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually, as is the case with textareas for
# posting comment replies (not the main comment box visible by default).
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).

$ ->
  AntCat.makeAllPreviewable()
  makeLoadingSpinnersAvailableForAtJs()

AntCat.makeAllPreviewable = -> $("textarea[data-previewable]").each -> $(this).makePreviewable()

$.fn.makePreviewable = -> new MakePreviewable this

class MakePreviewable
  # Tabs.
  TEXTAREA = "textarea"
  PREVIEW  = "preview"
  HELP     = "formatting-help"

  constructor: (@textarea) ->
    return if @isAlreadyPreviewable()

    @uuid = @getUUID()

    @wrapInPreviewArea()
    @setupPreviewLink()
    if @textarea.data('use-extras')
      new ExtrasArea(@textarea, @tab(TEXTAREA))

    @makeHelpTabsLoadableOnDemand()

    AntCat.setupLinkables()

  isAlreadyPreviewable: -> @textarea.parent().hasClass "tabs-panel"

  getUUID: ->
    window.currentUUID ||= 1
    currentUUID++

  # Very internal helpers.
  tab: (name) -> $(@tabId name)                     # jQuery element
  tabId: (name) -> "##{@unprefixedTabId name}"      # "#preview-tab-123"
  unprefixedTabId: (name) -> "#{name}-tab-#{@uuid}" # "preview-tab-123"

  # Helpers for finding links to the tabs.
  previewLink: -> $("a[href='#{@tabId PREVIEW}']")
  helpLink: ->    $("a[href='#{@tabId HELP}']")

  wrapInPreviewArea: ->
    # Create new preview area (tabs) and insert after textarea, and tabify.
    title = @textarea.data("previewable-title") || "Text"
    previewArea = @createPreviewArea title
    previewArea.insertAfter @textarea
    new Foundation.Tabs previewArea.find $(".tabs")

    # Move textarea inside the first tab of the preview area.
    @textarea.detach().prependTo @tab(TEXTAREA)

  # We need this ridiculous amount of unique IDs because Foundation
  # Tabs requires it. https://foundation.zurb.com/sites/docs/tabs.html
  # TODO probably do not use Foundation.
  createPreviewArea: (title) ->
    $ """
    <div class="preview-area">
      <ul class="tabs" data-tabs>
        <li class="tabs-title is-active">
          <a href="#{@tabId TEXTAREA}">#{title}</a>
        </li>
        <li class="tabs-title">
          <a href="#{@tabId PREVIEW}" class="preview-link">Preview</a>
        </li>
        <li class="tabs-title">
          <a href="#{@tabId HELP}">Formatting Help</a>
        </li>
        <li class="tabs-title right">
          <a>
            <span class="shared-spinner"><i class="fa fa-refresh fa-spin"></i></span>
          </a>
        </li>
      </ul>
      <div class="tabs-content">
        <div class="tabs-panel is-active" id="#{@unprefixedTabId TEXTAREA}"></div>
        <div class="tabs-panel" id="#{@unprefixedTabId PREVIEW}"></div>
        <div class="tabs-panel" id="#{@unprefixedTabId HELP}"></div>
      </div>
    </div>
    """

  setupPreviewLink: ->
    tab = @tab PREVIEW

    @previewLink().click (event) =>
      event.preventDefault()

      toParse = @textarea.val()
      if toParse is ""
        tab.html "No content. Try this: <code>{ta 429161}</code>."
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
          AntCat.make_reference_keeys_expandable tab
          @hideSpinner() # Only hide on success.
        error: -> tab.text "Error rendering preview"

  # Load markdown formatting help page via AJAX on demand.
  # Mostly because it's so much easier to format it in HAML rather than JavaScript.
  makeHelpTabsLoadableOnDemand: ->
    setupFormattingHelp = =>
      tab = @tab HELP
      url = "/markdown/formatting_help.json"

      @helpLink().click =>
        if tab.is ":empty"
          @showSpinner()
          tab.load url, =>
            @hideSpinner()
            AntCat.make_reference_keeys_expandable tab

    setupFormattingHelp()

  spinner: -> @textarea.closest(".preview-area").find ".shared-spinner"
  showSpinner: -> @spinner().show()
  hideSpinner: -> @spinner().hide()

class ExtrasArea
  DEFAULT_REFERENCE_BUTTON_ID = "default-reference-button"
  INSERT_REFERENCE_BUTTON_ID  = "insert-reference-button"
  INSERT_TAXON_BUTTON_ID      = "insert-taxon-button"

  constructor: (@textarea, @textareaTab) ->
    @createExtrasArea().appendTo @textareaTab
    @setupDefaultReferenceButton()
    @setupInsertTaxaButtons()
    @setupInsertReferenceButton()
    @setupInsertTaxonButton()

  createExtrasArea: ->
    $ """
    <div>
      <a id="#{DEFAULT_REFERENCE_BUTTON_ID}" class="btn-normal btn-tiny">Default reference</a>
      <a id="#{INSERT_REFERENCE_BUTTON_ID}" class="btn-normal btn-tiny">+Reference</a>
      <a id="#{INSERT_TAXON_BUTTON_ID}" class="btn-normal btn-tiny">+Taxon</a>
      <span id="extras-area"></span>
    </div>
    """

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
    reference = AntCat.defaultReference()
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
    taxa.forEach (taxon) =>
      @textareaTab.find('#extras-area').prepend insertTaxonButton(taxon.id, taxon.name)

    @textareaTab.find('.insert-taxon').click (event) =>
      event.preventDefault()
      id = $(event.target).data('id')
      @textarea.insertAtCaret "{tax #{id}} "

AntCat.defaultReference = ->
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
