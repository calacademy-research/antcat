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

  # Coming back soon!
  # setupFormattingHelp previewable, uuid

createPreviewArea = (previewable, uuid) ->
  title = previewable.data("previewable-title") || "Text"

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

    $.ajax
      url: '/preview_markdown'
      type: 'post'
      data: text: previewable.val()
      dataType: 'html'
      success: (html) ->
        $(previewArea).html html
        AntCat.setup_reference_keeys() # Re-trigger to make references expandable.
      error: -> $(previewArea).text "Error rendering preview"

# Currently not used.
$.fn.makeNotPreviewable = ->
  previewable = @
  previewArea = previewable.closest(".preview-area")
  previewable.insertAfter previewArea
  previewArea.remove()

$ ->
  $('*[data-previewable="true"]').makePreviewable()
