$.fn.previewMarkdownLink = (source, previewArea) ->
  @click (event) ->
    event.preventDefault()

    $.ajax
      url: '/preview_markdown'
      type: 'post'
      data: text: $(source).val()
      dataType: 'html'
      success: (html) -> $(previewArea).html html
      error: -> $(previewArea).text "Error rendering preview"

$ ->
  $("#task_preview_link").previewMarkdownLink "#task_description", "#preview"
  $("#site_notice_preview_link").previewMarkdownLink "#site_notice_message", "#preview"
