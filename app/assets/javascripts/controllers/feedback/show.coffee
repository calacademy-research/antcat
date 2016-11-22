$ ->
  forEmail = $("textarea#formatted_for_email")

  # Set height or the textarea will be like 3 rows in height.
  # Ugly because we can only get height if it's visible.
  forEmail.parent().show()
  forEmail.height forEmail[0].scrollHeight
  forEmail.parent().hide()

  # Be generous and select the content for the user.
  forEmail.on "mouseup", -> $(this)[0].select()
