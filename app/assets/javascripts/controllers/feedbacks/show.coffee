$ ->
  for_email = $("textarea#formatted_for_email")

  # Set height or the textarea will be like 3 rows in height.
  for_email.height for_email[0].scrollHeight

  # Be generous and select the content for the user.
  for_email.on "mouseup", -> $(this)[0].select()
