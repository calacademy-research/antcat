# Feedback modal
$ ->
  buildErrorString = (errorString) ->
    errors = $.parseJSON errorString

    message = ""
    for field, error_message of errors
      message += "#{field} #{error_message}"
    message

  renderErrors = (html) ->
    $("#feedback_errors").html """<p style="color: red">
      Whoops, error: #{html}</p>"""

  $("#new_feedback").on("ajax:success", (e, data, status, xhr) ->
    # Close form and add success notice.
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
