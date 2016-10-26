$ ->
  $("#dismiss_site_notices").click -> $.post "/site_notices/dismiss"
  $("#mark_all_site_notices_as_read").click -> $.post "/site_notices/mark_all_as_read"
