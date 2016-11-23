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
    # We could destroy the preview area here, but we don't have to (code in git).

closestReplyForm = (element) -> $(element).closest(".comment").find ".reply-form"
