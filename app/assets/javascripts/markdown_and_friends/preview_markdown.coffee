# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually, as is the case with textareas for
# posting comment replies (not the main comment box visible by default).
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).
#
# Code for inline autocompletion of users/taxa/references etc is
# independent of anything here.

$ ->
  $("textarea[data-previewable]").each -> $(this).makePreviewable()
  makeLoadingSpinnersAvailableForAtJs()

$.fn.makePreviewable = -> new MakePreviewable this

# All methods in this class except the constructor are "private",
# but prefixing all with underscores was just too ugly.
class MakePreviewable
  TEXTAREA = "textarea"
  PREVIEW  = "preview"
  HELP     = "formatting-help"

  constructor: (@textarea) ->
    return if @isAlreadyPreviewable()

    @uuid = @getUUID()

    @wrapInPreviewArea()
    @setupPreviewLink()
    @makeHelpTabsLoadableOnDemand()

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
        tab.html "No content. Try this: <code>%taxon429161</code>."
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
