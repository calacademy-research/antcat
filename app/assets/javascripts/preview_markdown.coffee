# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually, as is the case with textareas for
# posting comment replies (not the main comment box visible by default).
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).
#
# Code for inline autocompletion of users/taxa/references etc is
# independent of anything here, with the exception of setting up the
# "Enabled features" symbols in the textarea's upper right corner.

$ ->
  $("textarea[data-previewable]").makePreviewable()
  setupGlobalLoadingSpinnerTriggers()

# Makes *all* preview areas show the spinner, but that's OK.
ANY_PREVIEW_AREA_SPINNER = ".preview-area .shared-spinner"
showSpinner = -> $(ANY_PREVIEW_AREA_SPINNER).show()
hideSpinner = -> $(ANY_PREVIEW_AREA_SPINNER).hide()

# Use UUIDs so multiple textareas on the same page can be previewable.
window.currentUUID ||= 1
GetUUID = -> currentUUID++

# Global because we want at.js to be able to trigger it.
setupGlobalLoadingSpinnerTriggers = ->
  window.MDPreview =
    showSpinner: showSpinner
    hideSpinner: hideSpinner

$.fn.makePreviewable = -> new MakePreviewable this

# Currently not used.
$.fn.makeNotPreviewable = ->
  textarea = @
  previewArea = textarea.closest ".preview-area"
  textarea.insertAfter previewArea
  previewArea.remove()

# All methods in this class are "private", but prefixing all
# with underscores was just too ugly.
class MakePreviewable
  TEXTAREA = "textarea"
  PREVIEW  = "preview"
  HELP     = "formatting-help"
  SYMBOLS  = "symbols-explanation"

  constructor: (@textarea) ->
    return if @isAlreadyPreviewable()

    @uuid = GetUUID()

    @wrapInPreviewArea()
    @setupPreviewLink()
    @setSymbolsLabel()
    @makeHelpTabsLoadableOnDemand()
    @enableAreYouSure()

  isAlreadyPreviewable: -> @textarea.parent().hasClass "tabs-panel"

  # Very internal helpers.
  tab: (name) -> $(@tabId name)
  tabId: (name) -> "##{@unprefixedTabId name}"
  unprefixedTabId: (name) -> "#{name}-tab-#{@uuid}"

  # Helpers for finding links to the tabs.
  previewLink: -> $("a[href='#{@tabId PREVIEW}']")
  helpLink: ->    $("a[href='#{@tabId HELP}']")
  symbolsLink: -> $("a[href='#{@tabId SYMBOLS}']")

  wrapInPreviewArea: ->
    # Create new preview area (tabs) and insert after textarea, and tabify.
    title = @textarea.data("previewable-title") || "Text"
    previewArea = @createPreviewArea title
    previewArea.insertAfter @textarea
    new Foundation.Tabs previewArea.find $(".tabs")

    # Move textarea inside the first tab of the preview area.
    @textarea.detach().appendTo @tab(TEXTAREA)

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
          <a href="#{@tabId SYMBOLS}"></a>
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
        <div class="tabs-panel" id="#{@unprefixedTabId SYMBOLS}"></div>
      </div>
    </div>
    """

  setupPreviewLink: ->
    tab = @tab PREVIEW

    @previewLink().click (event) =>
      event.preventDefault()
      tab.html "Loading preview... dot dot dot..."
      showSpinner()

      $.ajax
        url: "/markdown/preview"
        type: "post"
        data: text: @textarea.val()
        dataType: "html"
        success: (html) =>
          tab.html html
          # Re-trigger to make references expandable.
          AntCat.make_reference_keeys_expandable tab
          hideSpinner() # Only hide on success.
        error: -> tab.text "Error rendering preview"

  # Show symbols of enabled features in the upper right corner.
  # Will most often look like this: `Enabled: md %trjif @`.
  # Clicking on the label shows explanations for them.
  #
  # It always includes at least "md", because markdown is always enabled if we
  # get here. It can tell if autocompletions for "linkables" and user
  # "mentionables" are enabled by looking at the textarea's data attributes.
  setSymbolsLabel: ->
    label = "md"
    label += " %trjif" if @textarea.data "has-linkables"
    label += " @"      if @textarea.data "has-mentionables"

    @symbolsLink().html "Enabled: <code>#{label}</code>"

  # Load markdown formatting help and symbols explanation pages via AJAX
  # on demand. Mostly becasue it's so much easier to format it in HAML
  # rather than JavaScript.
  makeHelpTabsLoadableOnDemand: ->
    setupFormattingHelp = =>
      tab = @tab HELP
      url = "/markdown/formatting_help.json"

      @helpLink().click =>
        if tab.is ":empty"
          showSpinner()
          tab.load url, ->
            hideSpinner()
            AntCat.make_reference_keeys_expandable tab

    setupSymbolsExplanations = =>
      tab = @tab SYMBOLS
      url = "/markdown/symbols_explanations.json"

      @symbolsLink().click =>
        if tab.is ":empty"
          showSpinner()
          tab.load url, -> hideSpinner()

    setupFormattingHelp()
    setupSymbolsExplanations()

  # jQuery plugin. "You have unsaved changes, leave form, ok??".
  enableAreYouSure: ->
    previewArea = @textarea.closest ".preview-area"
    previewArea.parents("form").areYouSure()
