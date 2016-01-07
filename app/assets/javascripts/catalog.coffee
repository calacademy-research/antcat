# I (jonk) *slightly* improved the layout by adding `magic_offset`s (they were already implicitly
# in the code, but now they have a name!). The layout is still very fragile: 1) browser renders
# elements slightly larger than expected 2) browser adds scrollbars, both vertical and horizontal
# 3) ??????
#
# Move the splitter downwards to see how toolbars still semi-randomly appear.
# We will probably have a new design by the time we have time to make this pretty.
splitter_top = 0
taxon_height = null

$ ->
  set_dimensions()
  setup_throbber()
  $(window).resize set_dimensions
  $('.edit_icon').show() if AntCat.testing
  splitter_top = $('#splitter').position().top
  splitter = new AntCat.Splitter $('#splitter'), on_splitter_change
  $('#delete_button')
 # .unbutton()
  .button()
  #.click -> window.location = $(@).data('delete-location')
  .click =>
    taxon_id = $('#delete_button').data('taxon-id')
    url = "/catalog/delete_impact_list/"+taxon_id
    $.ajax
      url: url,
      type: 'get',
      dataType: 'json',
      success: (data) =>
        confirm_delete_dialog(data,$('#delete_button').data('delete-location'))
      async: false,
      error: (xhr) => debugger

  $('#edit_button')
 # .unbutton()
  .button()
  .click -> window.location = $(@).data('edit-location')
  $('#review_button')
 # .unbutton()
  .button()
  .click -> window.location = $(@).data('review-location')
  $('#hide_all').remove()

confirm_delete_dialog = (data,destination) ->
  @delete_message = $('#delete_message')
  message = '<div id="delete-modal" title="This delete will remove the following taxa:"><p>
         <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>'

  message = message + '<ul>'
  for i in [1..data.length] by 1
    j = i - 1
    item = data[j]
    for k,v of item
      if(k != '__proto__')
        item = v
    message = message + '<li>' + item.name_html_cache + ", " + item.authorship_string + ": " + "created at: " + item.created_at

    message = message + '</li>'
  message = message + '</ul>'

  message = message + '</div></p></div>'
  @delete_message.append(message)
  dialog_box = $("#delete-modal")
  dialog_box.dialog({
    resizable: true,
    height: 280,
    width: 720,
    modal: true,
    buttons: {
      "Delete?": (a) =>
        window.location.href = destination
      ,
      "Cancel":
        id: "Cancel-Dialog"
        text: "Cancel"
        click: =>
          dialog_box.dialog("close")
    }
  })
  $('.delete_message').show()

setup_throbber = ->
  $('#navigation_bar form').submit ->
    $('#navigation_bar .submit').hide()
    $('#navigation_bar .throbber').show()

on_splitter_change = (top) ->
  top = $('#splitter').position().top
  delta = parseInt(top, 10) - splitter_top
  splitter_top = top
  taxon_height += delta
  set_height()
  $('#splitter').css 'top', 0
  url = '/taxon_window_height'
  data = {taxon_window_height: taxon_height}
  $.ajax url: url, data: data, type: 'put'

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
  $(".antcat_taxon").css 'min-height', calculate_taxon_height()
  $('#catalog .index').css 'height', ''

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
  session_height = $('.antcat_taxon').data 'taxon-window-height'
  return session_height if session_height
  page_height = $('#page').height()
  return 200 if page_height > 800
  return 90 if page_height > 600
  30

set_width = ->
  magic_offset = 24
  $('#catalog .antcat_taxon, #catalog').width ($('#page').width() - magic_offset)