panel_class = 'inline-form-panel'
panel_class_selector = '.' + panel_class

$ ->
  setup_page()
  setup_help()
  setup_icons()
  setup_reference_keys()
  setup_forms()

#--------------------------------------------------
setup_forms = ->
  $("#{panel_class_selector} .edit")
    .hide()
    .find('.submit')
      .live('click', submit_form)
    .end()
    .find('.cancel')
      .live('click', cancel_form)

show_form = ($panel, options) ->
  options = {} unless options
  $('.display', $panel).hide()
  $('.icon').hide() unless testing
  $('.edit', $panel).show()

submit_form = ->
  $(this).closest('form').ajaxSubmit
    success: update_form
    dataType: 'json'
  false

update_form = (data, statusText, xhr, $form) ->
  $panel = $('#item_' + (if data.isNew then "" else data.id))
  $edit = $('.edit', $panel)
  $spinnerElement = $('button', $edit).parent()
  $('input', $spinnerElement).attr 'disabled', ""
  $('button', $spinnerElement).attr 'disabled', ""
  $spinnerElement.spinner 'remove'
  $panel.parent().html data.content
  unless data.success
    $panel = $('#item_' + (if data.isNew then "" else data.id))
    show_form $panel
    return
  $panel = $('#item_' + data.id)
  $('.edit', $panel).hide()
  $('.display', $panel).show().effect 'highlight', {}, 3000

cancel_form = ->
  $panel = $(this).closest panel_class_selector
  unless $panel.attr('id') is 'item_'
    id = $panel.attr('id')
    restore_form $panel
    $panel = $('#' + id)
    $('.display', $panel).show().effect 'highlight', {}, 3000
  false

save_form = ($panel) ->
  $('#saved_item').remove()
  $panel.clone(true).attr('id', 'saved_item').appendTo('body').hide()

restore_form = ($panel) ->
  id = $panel.attr('id')
  $panel.replaceWith $('#saved_item')
  $('#saved_item').attr('id', id).show()

is_editing = ->
  false

#--------------------------------------------------
setup_icons = ->
  setup_icon_visibility()
  setup_icon_highlighting()
  setup_icon_click_handlers()

setup_icon_visibility = ->
  if not testing
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

edit = ->
  return false if is_editing()
  $panel = $(this).closest panel_class_selector
  save_form $panel
  show_form $panel
  false

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
  $('.reference_key').live 'click', expand_reference_key
  $('.reference_key_expansion_text').live 'click', expand_reference_key

expand_reference_key = ->
  $('.reference_key',           $(this).closest('.reference_key_and_expansion')).toggle()
  $('.reference_key_expansion', $(this).closest('.reference_key_and_expansion')).toggle()

#--------------------------------------------------
setup_help = ->
  setupQtip('.document_link', "Click to download and view the document")
  setupQtip('.goto_reference_link', "Click to view/edit this reference on its own page")
