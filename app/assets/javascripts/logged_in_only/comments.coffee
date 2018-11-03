$ ->
  setupCommentsReplyLinks()

setupCommentsReplyLinks = ->
  $(".comment-reply-link").click (event) ->
    event.preventDefault()

    replyForm = replyFormFor $(event.target)
    replyForm.show()
    replyForm.find("textarea").makePreviewable()

  $(".reply-form .btn-nodanger").click (event) ->
    event.preventDefault()
    $(event.target).parents(".reply-form").hide()

replyFormFor = (element) ->
  forComment = element.data "open-reply-form-for-comment"
  $(".reply-form[data-reply-form-for-comment='#{forComment}']")
