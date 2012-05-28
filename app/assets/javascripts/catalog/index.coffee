$ ->
  set_dimensions()
  $(window).resize set_dimensions
  $('.history_item').history_item_panel
    on_form_open: -> set_height 'auto'
    on_form_close: -> set_height 'fixed'
  $('.icon.edit').show() if AntCat.testing
  #$('.icon.edit').click() if AntCat.environment is 'development'
  $('.rank .genera .add a').click add_genus

add_genus = -> new AntCat.TaxonForm $('.new_taxon_form form')
  on_open: -> set_height: 'maxed'
  on_close: -> set_height: 'fixed'

set_dimensions = ->
  set_height()
  set_width()

set_height = (taxon_area_height = 'fixed') ->
  if taxon_area_height is 'fixed'
    set_fixed_height()
  else
    set_auto_height()
  set_catalog_height()

set_auto_height = ->
  $('#page').css 'overflow', 'auto'
  $(".antcat_taxon").height 'auto'
  $(".antcat_taxon").css 'min-height', '20em'

set_fixed_height = ->
  $('#page').css 'overflow', 'visible'
  $(".antcat_taxon").height '20em'
  $(".antcat_taxon").css 'min-height', ''

set_catalog_height = ->
  height = calculate_catalog_height()
  $("#catalog").height height
  $("#catalog .index").height height - $("#catalog .content").height()

calculate_catalog_height = ->
  $('#page').height() -
  $('#site_header').height() -
  $('#page_header').height() - 2 -
  $('#page_notice').height() -
  $('#page_alert').height() -
  $('#search_results').height() - 3 - 2 - 2 -
  $('#taxon_key').height() - 2 -
  $('#site_footer').height() - 8

set_width = ->
  $("#catalog .content").width $('#page').width()
