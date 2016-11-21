$.fn.makePreviewable = ->
  previewable = @
  # Return if previewable already is "previewable".
  return if previewable.parent().hasClass "tabs-panel"

  replacePreviewableWithPreviewArea previewable

replacePreviewableWithPreviewArea = (previewable) ->
  # Create UUID so multiple textareas on the same page can be previewable.
  uuid = AntCat.UUID()

  # Create new preview area (tabs) and insert after previewable (textarea).
  previewArea = createPreviewArea previewable, uuid
  $(previewArea).insertAfter previewable
  new Foundation.Tabs $("#tabs-#{uuid}")

  # Move previewable inside the preview area.
  previewable.detach().appendTo "#previewable-#{uuid}"

  # Make preview link work.
  previewLink = previewable.closest(".preview-area").find ".preview_link-#{uuid}"
  previewLink.previewMarkdownLink previewable, "#preview-#{uuid}"

  setupFormattingHelp previewable, uuid

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
        <a><span class='shared-spinner'><i class='fa fa-refresh fa-spin'></i></span></a>
      </li>
    </ul>
    <div class='tabs-content' data-tabs-content='tabs-#{uuid}'>
      <div class='tabs-panel is-active' id='previewable-#{uuid}'></div>
      <div class='tabs-panel' id='preview-#{uuid}'></div>
      <div class='tabs-panel' id='formatting_help-#{uuid}'></div>
    </div>
  </div>
  """

# TODO doesn't have to be a jQuery function.
$.fn.previewMarkdownLink = (previewable, previewArea) ->
  @click (event) ->
    event.preventDefault()

    $(previewArea).html "Loading preview... dot dot dot..."
    AntCat.showPreviewAreaSpinner()

    $.ajax
      url: '/markdown/preview'
      type: 'post'
      data: text: previewable.val()
      dataType: 'html'
      success: (html) ->
        $(previewArea).html html
        AntCat.make_reference_keeys_expandable previewArea # Re-trigger to make references expandable.
        AntCat.hidePreviewAreaSpinner() # Only hide on success.
      error: -> $(previewArea).text "Error rendering preview"

setupFormattingHelp = (previewable, uuid) ->
  $("#show_formatting_help-#{uuid}").click ->
    formatting_help = $("#formatting_help-#{uuid}")

    # Load markdown formatting help page via AJAX on demand.
    if formatting_help.is ':empty'
      AntCat.showPreviewAreaSpinner()
      formatting_help.html "Loading..."
      formatting_help.html $("<div>").load "/markdown/formatting_help.json", ->
        AntCat.hidePreviewAreaSpinner()

      # Add additional message if previewable has "linkables" (such as `%taxon`).
      if previewable.data "has-linkables"
        formatting_help.prepend """<p>
          Autocompletion is enabled for <code>%taxon</code> and
          <code>%reference</code> markdown links in this textarea.

          Start typing <code>%t</code> or <code>%r</code> followed by a search term
          (without a space before the search term), and select one of the suggestions.
          </p>"""

      # Add additional message if previewable has "mentionables" (ping users).
      if previewable.data "has-mentionables"
        formatting_help.prepend """<p>
          Mentionables are enabled for this textarea. Type <code>@</code>
          followed by another user's name or email, and select a user.
          NOTE: this *doesn't* send a notification to the user after saving
          this form, but that is on the roadmap.
          </p>"""

# Currently not used.
$.fn.makeNotPreviewable = ->
  previewable = @
  previewArea = previewable.closest(".preview-area")
  previewable.insertAfter previewArea
  previewArea.remove()

# TODO global, *uhh*, but "ok".
PREVIEW_AREA_SPINNER = ".preview-area .shared-spinner"
AntCat.showPreviewAreaSpinner = -> $(PREVIEW_AREA_SPINNER).show()
AntCat.hidePreviewAreaSpinner = -> $(PREVIEW_AREA_SPINNER).hide()

$ ->
  $('*[data-previewable="true"]').makePreviewable()
