$ ->
  $(".comment-reply-link, .reply-form .btn-cancel").click (event) ->
    event.preventDefault()
    $(this).closest(".comment").find(".reply-form").toggle()
