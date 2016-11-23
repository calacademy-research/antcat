$ ->
  setupCommentsReplyLinks()

setupCommentsReplyLinks = ->
  $(".comment-reply-link").click (event) ->
    event.preventDefault()

    replyForm = closestReplyForm this
    replyForm.show()
    replyForm.find(".previewable").makePreviewable()

  $(".reply-form .btn-cancel").click (event) ->
    event.preventDefault()
    closestReplyForm(this).hide()
    # We could use this to make the textarea not previewable, but we don't have to.
    # closestReplyForm.find(".previewable").makeNotPreviewable() # TODO see if we want to.

closestReplyForm = (element) -> $(element).closest(".comment").find ".reply-form"
