$ ->
  preload_images()
  space_out_images()
  $(window).resize space_out_images
  setup_login()
  setup_reference_keys()
  $('input[type=text]:visible:first').focus()

preload_images = ->
  for image in ['/assets/header_bg.png', '/assets/antcat_logo.png', '/assets/site_header_ant_5.png', '/assets/ui-anim_basic_16x16.gif']
    (new Image()).src = image

AntCat or= {}
AntCat.spinner_path = '/assets/ui-anim_basic_16x16.gif'

space_out_images = ->
  total_image_width = 379 + 154 + 124
  image_count = 7
  available_width = $('#site_footer .images').width()
  margin_in_between = (available_width - total_image_width) / (image_count - 1)
  $("#site_footer .spacer").width margin_in_between

setup_login = ->
  $('#login .form').hide()
  $('#login a.link').click -> $('#login div').toggle()

#_something seems to override this method when it's named
# enable - it doesn't get called
$.fn.undisable = ->
  $(this).removeClass 'ui-state-disabled'

$.fn.disable = ->
  $(this).addClass 'ui-state-disabled'

setup_reference_keys = ->
  $('.reference_key, .reference_key_expansion_text').live 'click', ->
    $(this)
      .closest('.reference_key_and_expansion')
      .find('.reference_key, .reference_key_expansion')
      .toggle()
