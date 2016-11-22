# This makes all textareas with `data-previewable="true"` previewable.
# Can also be invoked manually, as is the case with textareas for
# posting comment replies (not the non-dynamic main comment box).
#
# "Previewable" means markdown in the textarea can be previewed (rendered
# server-side as HTML and return to the client).
#
# Code for inline autocompletion of users/taxa/references etc is
# independent of anything here, with the exception of setting up the
# "Enabled features" symbols in the textarea's upper right corner.

$ ->
  $('textarea[data-previewable="true"]').makePreviewable()

# Use UUID so multiple textareas on the same page can be previewable.
UUID = ->
  @currentUUID ||= 1
  currentUUID++

PREVIEW_AREA_SPINNER = ".preview-area .shared-spinner"
showSpinner = -> $(PREVIEW_AREA_SPINNER).show()
hideSpinner = -> $(PREVIEW_AREA_SPINNER).hide()

# Make global so at.js can trigger the loading spinner.
window.MDPreview ||= {}
MDPreview.showSpinner = showSpinner
MDPreview.hideSpinner = hideSpinner

$.fn.makePreviewable = ->
  previewable = @
  # Return if previewable already is "previewable".
  return if previewable.parent().hasClass "tabs-panel"

  replacePreviewableWithPreviewArea previewable

# Currently not used.
$.fn.makeNotPreviewable = ->
  previewable = @
  previewArea = previewable.closest(".preview-area")
  previewable.insertAfter previewArea
  previewArea.remove()

replacePreviewableWithPreviewArea = (previewable) ->
  uuid = UUID()

  # Create new preview area (tabs) and insert after previewable (textarea).
  previewArea = createPreviewArea previewable, uuid
  $(previewArea).insertAfter previewable
  new Foundation.Tabs $("#tabs-#{uuid}")

  # Move previewable inside the preview area.
  previewable.detach().appendTo "#previewable-#{uuid}"

  # Make preview link work.
  previewLink = previewable.closest(".preview-area").find ".preview_link-#{uuid}"
  previewLink.previewMarkdownLink previewable, "#preview-#{uuid}"

  # Setup help links.
  setupFormattingHelp previewable, uuid
  setupSymbolsExplanations previewable, uuid

  # jQuery plugin. "You have unsaved changes, leave form, ok??".
  $(".preview-area").parents("form").areYouSure()

createPreviewArea = (previewable, uuid) ->
  title = previewable.data("previewable-title") || "Text"

  # Spinner CSS duplicated from `ApplicationHelper#shared_spinner_icon`.
  """
  <div class="preview-area">
    <ul class='tabs' data-tabs='' id='tabs-#{uuid}'>
      <li class='tabs-title is-active'>
        <a href="#previewable-#{uuid}">#{title}</a>
      </li>
      <li class='tabs-title'>
        <a class="preview_link-#{uuid}" href="#preview-#{uuid}">Preview</a>
      </li>
      <li class='tabs-title'>
        <a id="show_formatting_help-#{uuid}" href="#formatting_help-#{uuid}">Formatting Help</a>
      </li>
      <li class='tabs-title right'>
        <a href="#symbols-explanations-#{uuid}" id="symbols-explanations-link-#{uuid}"
          title="Click for more info">
          Enabled: <code id="symbols-explanations-labels-#{uuid}"></code>
        </a>
      </li>
      <li class='tabs-title right'>
        <a><span class='shared-spinner'><i class='fa fa-refresh fa-spin'></i></span></a>
      </li>
    </ul>
    <div class='tabs-content' data-tabs-content='tabs-#{uuid}'>
      <div class='tabs-panel is-active' id='previewable-#{uuid}'></div>
      <div class='tabs-panel' id='preview-#{uuid}'></div>
      <div class='tabs-panel' id='formatting_help-#{uuid}'></div>
      <div class='tabs-panel' id='symbols-explanations-#{uuid}'></div>
    </div>
  </div>
  """

# TODO doesn't have to be a jQuery function.
$.fn.previewMarkdownLink = (previewable, previewArea) ->
  @click (event) ->
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

# Load markdown formatting help page via AJAX on demand.
setupFormattingHelp = (previewable, uuid) ->
  $("#show_formatting_help-#{uuid}").click ->
    formatting_help = $("#formatting_help-#{uuid}")

    if formatting_help.is ':empty'
      showSpinner()
      formatting_help.html "Loading..."
      formatting_help.html $("<div>").load "/markdown/formatting_help.json", ->
        hideSpinner()
        AntCat.make_reference_keeys_expandable formatting_help

# Show symbols of enabled features in the upper right corner.
# Will most often look like this: `Enabled: md %trjif @`.
# Clickong on the label shows explanations for them.
setupSymbolsExplanations = (previewable, uuid) ->
  label = "md" # Markdown is always enabled if we get here.
  label += " %trjif" if previewable.data "has-linkables"
  label += " @" if previewable.data "has-mentionables"
  $("#symbols-explanations-labels-#{uuid}").html label

  # Load symbols explanations via AJAX on demand.
  $("#symbols-explanations-link-#{uuid}").click ->
    symbolsExplanations = $("#symbols-explanations-#{uuid}")
    if symbolsExplanations.is ':empty'
      showSpinner()
      symbolsExplanations.html "Loading..."
      symbolsExplanations.html $("<div>").load "/markdown/symbols_explanations.json", ->
        hideSpinner()
