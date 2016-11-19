$ ->
  $(".comment-reply-link").click (event) ->
    event.preventDefault()

    closestReplyForm = $(this).closest(".comment").find(".reply-form")
    closestReplyForm.show()
    closestReplyForm.find(".previewable").makePreviewable()

  $(".reply-form .btn-cancel").click (event) ->
    event.preventDefault()

    closestReplyForm = $(this).closest(".comment").find(".reply-form")
    closestReplyForm.hide()
    # We could use this to make the textarea not previewable, but we don't have to.
    # closestReplyForm.find(".previewable").makeNotPreviewable() # TODO see if we want to.
