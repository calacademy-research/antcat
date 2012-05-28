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
    $("#page").height '100%'
    $(".antcat_taxon").height '20em'
    $(".antcat_taxon").css 'min-height', ''

    height = $('#page').height() -
      $('#site_header').height() -
      $('#page_header').height() - 2 -
      $('#page_notice').height() -
      $('#page_alert').height() -
      $('#search_results').height() - 3 - 2 - 2 -
      $('#taxon_key').height() - 2 -
      $('#site_footer').height() - 8
    $("#catalog").height height
    $("#catalog .index").height height - $("#catalog .content").height()

  else
    $("#page").height 'auto'
    $(".antcat_taxon").height 'auto'
    $(".antcat_taxon").css 'min-height', '20em'
    $("#catalog").height 'auto'
    $("#catalog .index").height 'auto'

set_width = ->
  $("#catalog .content").width $('#page').width()
