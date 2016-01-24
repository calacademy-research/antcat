# I (jonk) *slightly* improved the layout by adding `magic_offset`s (they were already implicitly
# in the code, but now they have a name!). The layout is still very fragile: 1) browser renders
# elements slightly larger than expected 2) browser adds scrollbars, both vertical and horizontal
# 3) ??????
#
# Move the splitter downwards to see how toolbars still semi-randomly appear.
# We will probably have a new design by the time we have time to make this pretty.

splitter_top = 0
taxon_height = null

class AntCat.Splitter
  constructor: (@element, @on_change) ->
    @element.draggable(axis: 'y', cursor: 'row-resize', stop: @stop)

  stop: =>
    @on_change(@element.css('top')) if @on_change

$ ->
  taxon_height_cookie = parseFloat Cookies.get('taxon_height')
  taxon_height = taxon_height_cookie if taxon_height_cookie
  set_dimensions()
  $(window).resize set_dimensions
  splitter_top = $('#splitter').position().top
  splitter = new AntCat.Splitter $('#splitter'), on_splitter_change

on_splitter_change = (top) ->
  top = $('#splitter').position().top
  delta = parseInt(top, 10) - splitter_top
  splitter_top = top
  taxon_height += delta
  set_height()
  $('#splitter').css 'top', 0
  Cookies.set 'taxon_height', taxon_height

set_dimensions = ->
  set_height()
  set_width()

set_height = ->
  set_fixed_height()
  height = calculate_catalog_height()
  set_catalog_height(height)

# unreachable function `set_auto_height` was removed from here

set_fixed_height = ->
  $('#page').css 'overflow', 'inherit'
  taxon_height = calculate_taxon_height()
  $(".antcat_taxon").height taxon_height
  $(".antcat_taxon").css 'min-height', ''
  $('.antcat_taxon').css 'overflow', ''

set_catalog_height = (height) ->
  magic_offset = 7 + 2 + 2 + 2
  # #catalog margin-top: 2
  # hr: 2
  # .antcat_taxon margin-bottom: 2
  # #splitter: 7
  $("#catalog .index").height height - $("#catalog .antcat_taxon").height() - magic_offset

calculate_catalog_height = ->
  magic_offset = 2 + 3 + 2 + 2 + 2
  # hr: 2
  # #page_contents padding-bottom: 3
  # #catalog margin-top: 2
  # hr *inside* #page_contents: 2
  # hr : 2
  $('#page').height() -
    $('#site_header').height() -
    $('#page_header').height() -
    $('#page_notice').height() -
    $('#page_alert').height() -
    $('#search_results').outerHeight(true) -
    $('#taxon_key').height() -
    $('#site_footer').height() -
    magic_offset

calculate_taxon_height = ->
  return taxon_height if taxon_height?
  page_height = $('#page').height()
  return 200 if page_height > 800
  return 90 if page_height > 600
  90

set_width = ->
  magic_offset = 24
  $('#catalog .antcat_taxon, #catalog').width ($('#page').width() - magic_offset)