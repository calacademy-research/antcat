$ ->
  setupPage()
  setupHelp()
  setupIcons()
  setupReferenceKeys()
  setupTaxtEditBoxes()

setupTaxtEditBoxes = ->
  $('.taxt_edit_box').taxt_edit_box()
  $('.taxt_edit_box').first().focus()

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
  if user_can_edit
    setupIconHighlighting()
    setupIconClickHandlers()

setupIconVisibility = ->
  if not testing or not user_can_edit
    $('.icon').hide()

  return unless user_can_edit

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
