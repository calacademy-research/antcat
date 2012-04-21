$ ->
  space_out_images()
  $(window).resize space_out_images
  setup_login()
  $('input[type=text]:visible:first').focus()

space_out_images = ->
  total_image_width = 379 + 154 + 124
  image_count = 7
  available_width = $('#site_footer .images').width()
  margin_in_between = (available_width - total_image_width) / (image_count - 1)
  $("#site_footer .spacer").width margin_in_between

setup_login = ->
  $('#login .form').hide()
  $('#login a.link').click -> $('#login div').toggle()

#_something seems to overrie this method - it doesn't get called
#$.fn.enable = ->
  #$(this).removeClass 'ui-state-disabled'

$.fn.disable = ->
  $(this).addClass 'ui-state-disabled'
