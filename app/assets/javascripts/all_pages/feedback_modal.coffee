# The Feedback modal is included on all pages.

$ ->
  setupFeedbackModal()

setupFeedbackModal = ->
  $("#new_feedback").on("ajax:success", (e, data, status, xhr) ->
    # Close form and add success notice.
    # TODO: this skips the animation.
    $("#feedback_modal").foundation "close"
    $("#content").prepend data.feedback_success_callout

    # Clear comment/errors (but keep name/email).
    $("#feedback_errors").html ""
    $("#feedback_comment").val ""

  ).on "ajax:error", (e, xhr, status, error) ->
    try
      errors = buildErrorString xhr.responseText
      renderErrors errors
    catch
      renderErrors "unknown error"

  buildErrorString = (errorString) ->
    errors = $.parseJSON errorString
    return errors["rate_limited"] if "rate_limited" of errors

    message = ""
    for field, error_message of errors
      message += "#{field} #{error_message}"
    message

  renderErrors = (html) ->
    $("#feedback_errors").html """<p class="bold-warning">
      Whoops, error: #{html}</p>"""
