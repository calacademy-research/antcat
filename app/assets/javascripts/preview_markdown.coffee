$.fn.previewMarkdownLink = (source, previewArea) ->
  @click (event) ->
    event.preventDefault()

    $.ajax
      url: '/preview_markdown'
      type: 'post'
      data: text: $(source).val()
      dataType: 'html'
      success: (html) ->
        $(previewArea).html html
      error: ->
        $(previewArea).text "Error rendering preview"

$ ->
  $("#preview_link").previewMarkdownLink "#task_description", "#preview"
