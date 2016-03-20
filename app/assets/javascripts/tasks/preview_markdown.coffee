$ ->
  $("#preview_markdown_link").click (event) ->
    event.preventDefault()

    $.ajax
      url: '/tasks/preview_markdown'
      type: 'post'
      data: task_description: $("#task_description").val()
      dataType: 'html'
      success: (html) ->
        $("#preview").html html
      error: ->
        $("#preview").text "Error rendering preview"
