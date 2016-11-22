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
  $('textarea[data-previewable="true"]').makePreviewable()

  setupGlobalLoadingSpinnerTriggers()

# Makes *any* preview areas show the spinner, but that's OK.
ANY_PREVIEW_AREA_SPINNER = ".preview-area .shared-spinner"
showSpinner = -> $(ANY_PREVIEW_AREA_SPINNER).show()
hideSpinner = -> $(ANY_PREVIEW_AREA_SPINNER).hide()

$.fn.makePreviewable = ->
  previewable = @
  # Return if textarea already is "previewable".
  return if previewable.parent().hasClass "tabs-panel"

  wrapPreviewableInsidePreviewArea previewable

# Currently not used.
$.fn.makeNotPreviewable = ->
  previewable = @
  previewArea = previewable.closest(".preview-area")
  previewable.insertAfter previewArea
  previewArea.remove()

wrapPreviewableInsidePreviewArea = (previewable) ->
  uuid = UUID()

  # Create new preview area (tabs) and insert after previewable (textarea).
  previewArea = createPreviewArea previewable, uuid
  $(previewArea).insertAfter previewable
  new Foundation.Tabs $("#tabs-#{uuid}")

  # Move previewable inside the preview area.
  previewable.detach().appendTo "#previewable-tab-#{uuid}"

  # Make preview link work.
  setupPreviewLink previewable, uuid

  # Setup help links.
  setupFormattingHelp previewable, uuid
  setupSymbolsExplanations previewable, uuid

  # jQuery plugin. "You have unsaved changes, leave form, ok??".
  $("#preview-area-#{uuid}").parents("form").areYouSure()

# Use UUID so multiple textareas on the same page can be previewable.
UUID = ->
  @currentUUID ||= 1
  currentUUID++

# We need this ridiculous amount of unique IDs because Foundation
# Tabs requires it. https://foundation.zurb.com/sites/docs/tabs.html
# TODO probably do not use Foundation.
createPreviewArea = (previewable, uuid) ->
  title = previewable.data("previewable-title") || "Text"

  # Spinner CSS duplicated from `ApplicationHelper#shared_spinner_icon`.
  """
  <div id="preview-area-#{uuid}" class="preview-area">
    <ul class='tabs' data-tabs='' id='tabs-#{uuid}'>
      <li class='tabs-title is-active'>
        <a href="#previewable-tab-#{uuid}">#{title}</a>
      </li>
      <li class='tabs-title'>
        <a class="preview-link" href="#preview-tab-#{uuid}">Preview</a>
      </li>
      <li class='tabs-title'>
        <a id="show-formatting-help-#{uuid}" href="#formatting-help-tab-#{uuid}">Formatting Help</a>
      </li>
      <li class='tabs-title right'>
        <a href="#symbols-explanations-tab-#{uuid}" id="symbols-explanations-link-#{uuid}"
          title="Click for more info">
          Enabled: <code id="symbols-explanations-labels-#{uuid}"></code>
        </a>
      </li>
      <li class='tabs-title right'>
        <a><span class='shared-spinner'><i class='fa fa-refresh fa-spin'></i></span></a>
      </li>
    </ul>
    <div class='tabs-content' data-tabs-content='tabs-#{uuid}'>
      <div class='tabs-panel is-active' id='previewable-tab-#{uuid}'></div>
      <div class='tabs-panel' id='preview-tab-#{uuid}'></div>
      <div class='tabs-panel' id='formatting-help-tab-#{uuid}'></div>
      <div class='tabs-panel' id='symbols-explanations-tab-#{uuid}'></div>
    </div>
  </div>
  """

setupPreviewLink = (previewable, uuid) ->
  previewArea = "#preview-tab-#{uuid}"
  previewLink = previewable.closest(".preview-area").find ".preview-link"

  previewLink.click (event) ->
    event.preventDefault()

    $(previewArea).html "Loading preview... dot dot dot..."
    showSpinner()

    $.ajax
      url: '/markdown/preview'
      type: 'post'
      data: text: previewable.val()
      dataType: 'html'
      success: (html) ->
        $(previewArea).html html
        AntCat.make_reference_keeys_expandable previewArea # Re-trigger to make references expandable.
        hideSpinner() # Only hide on success.
      error: -> $(previewArea).text "Error rendering preview"

# Load markdown formatting help page via AJAX on demand. Mostly becasue
# it's so much easier to format it in HAML rather than JavaScript.
setupFormattingHelp = (previewable, uuid) ->
  $("#show-formatting-help-#{uuid}").click ->
    formattingHelp = $("#formatting-help-tab-#{uuid}")

    if formattingHelp.is ':empty'
      showSpinner()
      formattingHelp.html "Loading..."
      formattingHelp.html $("<div>").load "/markdown/formatting_help.json", ->
        hideSpinner()
        AntCat.make_reference_keeys_expandable formattingHelp

# Show symbols of enabled features in the upper right corner.
# Will most often look like this: `Enabled: md %trjif @`.
# Clicking on the label shows explanations for them.
#
# It always includes at least "md", because markdown is always enabled if we
# get here. It can tell if autocompletions for "linkables" and user
# "mentionables" are enabled by looking at the textarea's data attributes.
setupSymbolsExplanations = (previewable, uuid) ->
  label = "md"
  label += " %trjif" if previewable.data "has-linkables"
  label += " @" if previewable.data "has-mentionables"
  $("#symbols-explanations-labels-#{uuid}").html label

  # Load symbols explanations via AJAX on demand. Also, HAML > HTML +JS.
  $("#symbols-explanations-link-#{uuid}").click ->
    symbolsExplanations = $("#symbols-explanations-tab-#{uuid}")
    if symbolsExplanations.is ':empty'
      showSpinner()
      symbolsExplanations.html "Loading..."
      symbolsExplanations.html $("<div>").load "/markdown/symbols_explanations.json", ->
        hideSpinner()

setupGlobalLoadingSpinnerTriggers = ->
  window.MDPreview =
    showSpinner: showSpinner
    hideSpinner: hideSpinner
