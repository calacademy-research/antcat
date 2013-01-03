$ ->
  splitter = new AntCat.Splitter $('#splitter'), on_splitter_change
  set_dimensions()
  $(window).resize set_dimensions
  $('.history_item').history_item_panel
    on_form_open: -> set_height 'auto'
    on_form_close: -> set_height 'fixed'
  $('.icon.edit').show() if AntCat.testing

on_splitter_change = (top) ->
  #set_height_from_splitter top

set_dimensions = ->
  set_height()
  set_width()

set_height = (taxon_area_height = 'fixed') ->
  if taxon_area_height is 'fixed'
    set_fixed_height()
    height = calculate_catalog_height()
    set_catalog_height(height)
  else
    set_auto_height()

set_auto_height = ->
  $('#page').css 'overflow', 'auto'
  $(".antcat_taxon").height 'auto'
  $(".antcat_taxon").css 'min-height', calculate_taxon_height
  $('#catalog .index').css 'height', ''

set_fixed_height = ->
  $('#page').css 'overflow', 'inherit'
  $(".antcat_taxon").height calculate_taxon_height
  $(".antcat_taxon").css 'min-height', ''

set_catalog_height = (height) ->
  $("#catalog").height height
  $("#catalog .index").height height - $("#catalog .taxon").height()

calculate_catalog_height = ->
  $('#page').height() -
  $('#site_header').height() -
  $('#page_header').height() - 2 -
  $('#page_notice').height() -
  $('#page_alert').height() -
  $('#search_results').height() - 3 - 2 - 2 -
  $('#taxon_key').height() - 2 -
  $('#site_footer').height() - 8

calculate_taxon_height = ->
  page_height = $('#page').height()
  return 200 if page_height > 800
  return 90 if page_height > 600
  30

set_width = ->
  $("#catalog .taxon, #catalog .new_taxon_form").width $('#page').width()
