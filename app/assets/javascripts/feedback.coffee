# Feedback modal
$ ->
  $("#new_feedback").on("ajax:success", (e, data, status, xhr) ->
    # Close form.
    $("#feedback_modal").foundation "close"

    # Clear comment/errors (but keep name/email).
    $("#feedback_errors").html ""
    $("#feedback_comment").val ""

  ).on "ajax:error", (e, xhr, status, error) ->
    $("#feedback_errors").html """<p style="color: red">
      Whoops, error. Is the comment field blank?</p>"""
