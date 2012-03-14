panel_class = 'inline-form-panel'
panel_class_selector = '.' + panel_class

$ ->
  setupPage()
  setupHelp()
  setupIcons()
  setupReferenceKeys()
  setupEdits()

setupEdits = ->
  $("#{panel_class_selector} .edit").hide()
  $("#{panel_class_selector} .edit .submit").live 'click', submitReferenceEdit
  $("#{panel_class_selector} .edit .cancel").live 'click', cancelReferenceEdit
  $('.taxt_edit_box').taxt_edit_box()

submitReferenceEdit = ->
  $(this).closest('form').ajaxSubmit
    beforeSubmit: setupSubmit
    success: updateReference
    dataType: 'json'
  false

cancelReferenceEdit = ->
  $reference = $(this).closest panel_class_selector
  unless $reference.attr('id') is 'reference_'
    id = $reference.attr('id')
    restoreReference $reference
    $reference = $('#' + id)
    $('.display', $reference).show().effect 'highlight', {}, 3000
  false

restoreReference = ($reference) ->
  id = $reference.attr('id')
  $reference.replaceWith $('#saved_reference')
  $('#saved_reference').attr('id', id).show()

setupPage = ->
  setDimensions()
  $(window).resize = setDimensions

setDimensions = ->
  setHeight()
  setWidth()

setHeight = ->
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

setWidth = ->
  $("#catalog .content").width($('#page').width())

setupReferenceKeys = ->
  $('.reference_key').live('click', expandReferenceKey)
  $('.reference_key_expansion_text').live('click', expandReferenceKey)

expandReferenceKey = ->
  $('.reference_key',           $(this).closest('.reference_key_and_expansion')).toggle()
  $('.reference_key_expansion', $(this).closest('.reference_key_and_expansion')).toggle()

setupHelp = ->
  setupQtip('.document_link', "Click to download and view the document")
  setupQtip('.goto_reference_link', "Click to view/edit this reference on its own page")

isEditing = ->
  false

setupIcons = ->
  setupIconVisibility()
  setupIconHighlighting()
  setupIconClickHandlers()

setupIconVisibility = ->
  if not testing
    $('.icon').hide()

  $('.history_item').live('mouseenter',
    ->
      unless isEditing()
        $('.icon', $(this)).show()
    ).live('mouseleave',
    ->
      $('.icon').hide()
    )

setupIconHighlighting = ->
  $('.icon img').live('mouseenter',
    ->
      this.src = this.src.replace('off', 'on')
    ).live('mouseleave',
    ->
      this.src = this.src.replace('on', 'off')
    )

setupIconClickHandlers = ->
  $('.icon.edit').live('click', editHistoryItem)

editHistoryItem = ->
  return false if isEditing()
  $panel = $(this).closest panel_class_selector
  saveReference $panel
  showReferenceEdit $panel
  false

saveReference = ($reference) ->
  $('#saved_reference').remove()
  $reference.clone(true).attr('id', 'saved_reference').appendTo('body').hide()

showReferenceEdit = ($reference, options) ->
  options = {} unless options
  $('.display', $reference).hide()
  $('.icon').hide() unless testing
  $('.edit', $reference).show()
