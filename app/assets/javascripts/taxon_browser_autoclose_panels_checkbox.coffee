$ ->
  $("#close_inactive_panels").change ->
    Cookies.set "close_inactive_panels", $(this).is(":checked")
