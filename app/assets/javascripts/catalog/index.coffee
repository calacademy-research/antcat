$ ->
  set_dimensions()
  $(window).resize set_dimensions
  $('.history_item').history_item_panel on_edit_opened: set_dimensions
  $('.icon.edit').show() if AntCat.testing
  #$('.icon.edit').click() if AntCat.environment is 'development'

set_dimensions = ->
  set_height()
  set_width()

set_height = ->
  if AntCat.HistoryItemPanel.is_editing()
    $("#page").height('auto')
    $(".antcat_taxon").height('auto')
  else
    $("#page").height('100%')
    $(".antcat_taxon").height('20em')

  height = $('#page').height() -
    $('#site_header').height() -
    $('#page_header').height() - 2 -
    $('#page_notice').height() -
    $('#page_alert').height() -
    $('#search_results').height() - 3 - 2 - 2 -
    $('#taxon_key').height() - 2 -
    $('#site_footer').height() - 8

  if AntCat.HistoryItemPanel.is_editing()
    $("#catalog").height('auto')
    $("#catalog .index").height('auto')
  else
    $("#catalog").height(height)
    $("#catalog .index").height(height - $("#catalog .content").height())

set_width = ->
  $("#catalog .content").width($('#page').width())
