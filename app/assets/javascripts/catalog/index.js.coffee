panel_class = 'inline-form-panel'
panel_class_selector = '.' + panel_class

$ ->
  setup_page()
  setup_help()
  setup_icons()
  setup_reference_keys()
  setup_forms()

  $('.icon.edit').click() unless AntCat.testing

#--------------------------------------------------
setup_forms = ->
  $("#{panel_class_selector} div.edit")
    .hide()
    .find('.submit')
      .live('click', submit_form)
    .end()
    .find('.cancel')
      .live('click', cancel_form)

#--------------------------------------------------
edit = ->
  return false if is_editing()
  $panel = $(this).closest panel_class_selector
  save_form $panel
  show_form $panel
  false

show_form = ($panel, options) ->
  options = {} unless options
  $('div.display', $panel).hide()
  $('.icon').hide() unless AntCat.testing
  $('div.edit', $panel).show()

submit_form = ->
  $(this).closest('form').ajaxSubmit
    beforeSubmit: setup_submit
    success: update_form
    error: handle_error
    dataType: 'json'
  false

setup_submit = (formData, $form, options) ->
  start_spinning $form

start_spinning = ($form) ->
  $spinnerElement = $(':button', $form).parent()
  $spinnerElement.spinner position: 'left', img: '/assets/ui-anim_basic_16x16.gif'
  #spinnerElement.spinner({position: 'left', img: "<%= asset_path('ui-anim_basic_16x16.gif') %>"})
  $(':button', $spinnerElement).attr 'disabled', 'disabled'

stop_spinning = ($edit) ->
  $spinnerElement = $('.spinner')
  $(':button', $spinnerElement).removeAttr 'disabled'
  $spinnerElement.spinner 'remove'

update_form = (data, statusText, xhr, $form) ->
  stop_spinning()
  $panel = $('#item_' + (if data.isNew then "" else data.id))
  $edit = $('div.edit', $panel)
  $panel.parent().html data.content
  unless data.success
    $panel = $('#item_' + (if data.isNew then "" else data.id))
    show_form $panel
    return
  $panel = $('#item_' + data.id)
  $('div.edit', $panel).hide()
  $('div.display', $panel).show().effect 'highlight', {}, 3000

handle_error = (jq_xhr, text_status, error_thrown) ->
  stop_spinning()
  alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

cancel_form = ->
  $panel = $(this).closest panel_class_selector
  unless $panel.attr('id') is 'item_'
    id = $panel.attr('id')
    restore_form $panel
    $panel = $('#' + id)
    $('div.edit', $panel).hide()
    $('div.display', $panel).show().effect 'highlight', {}, 3000
  false

original_value_key = panel_class + '_original_value'
save_form = ($panel) ->
  $taxt_edit_box = $('textarea', $panel)
  $taxt_edit_box.data original_value_key, $taxt_edit_box.val()

restore_form = ($panel) ->
  $taxt_edit_box = $('textarea', $panel)
  $taxt_edit_box.val $taxt_edit_box.data original_value_key

is_editing = ->
  $("#{panel_class_selector} div.edit").is ':visible'

#--------------------------------------------------
setup_page = ->
  set_dimensions()
  $(window).resize = set_dimensions

set_dimensions = ->
  set_height()
  set_width()
set_height = ->
  height = $('#page').height() -
    $('#site_header').height() -
    $('#page_header').height() - 2 -
    $('#page_notice').height() -
    $('#page_alert').height() -
    $('#search_results').height() - 3 - 2 - 2 -
    $('#taxon_key').height() - 2 -
    $('#site_footer').height() - 8
  $("#catalog").height(height)
  $("#catalog .index").height(height - $("#catalog .content").height())

set_width = ->
  $("#catalog .content").width($('#page').width())

#--------------------------------------------------
setup_reference_keys = ->
  $('.reference_key').live 'click', toggle_reference_key_expansion
  $('.reference_key_expansion_text').live 'click', toggle_reference_key_expansion

toggle_reference_key_expansion = ->
  $('.reference_key',           $(this).closest('.reference_key_and_expansion')).toggle()
  $('.reference_key_expansion', $(this).closest('.reference_key_and_expansion')).toggle()

#--------------------------------------------------
setup_help = ->
  setupQtip('.document_link', "Click to download and view the document")
  setupQtip('.goto_reference_link', "Click to view/edit this reference on its own page")

#--------------------------------------------------
setup_icons = ->
  setup_icon_visibility()
  setup_icon_highlighting()
  setup_icon_click_handlers()

setup_icon_visibility = ->
  if not AntCat.testing
    $('.icon').hide()

  $('.history_item').live('mouseenter',
    ->
      unless is_editing()
        $('.icon', $(this)).show()
    ).live('mouseleave',
    ->
      $('.icon').hide()
    )

setup_icon_highlighting = ->
  $('.icon img').live('mouseenter',
    ->
      this.src = this.src.replace 'off', 'on'
    ).live('mouseleave',
    ->
      this.src = this.src.replace 'on', 'off'
    )

setup_icon_click_handlers = ->
  $('.icon.edit').live 'click', edit
