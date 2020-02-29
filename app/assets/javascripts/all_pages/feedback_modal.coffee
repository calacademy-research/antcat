$ ->
  setupFeedbackModal()

setupFeedbackModal = ->
  $('#submit-feedback-js').click (event) ->
    event.preventDefault()

    Rails.ajax
      url: "/feedback"
      type: "POST"
      data: $("#new_feedback").serialize()
      success: (data) ->
        $("#feedback_modal").foundation "close"
        $("#content").prepend data

        # Clear comment/errors (but keep name/email).
        $("#feedback_errors").html ""
        $("#feedback_comment").val ""
      error: (data) -> $("#feedback_errors").html """<p class="bold-warning">Whoops, error: #{data}</p>"""
