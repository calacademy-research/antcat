$(function() {
  setupPage();
})

function setupPage() {
  setPageHeight();
  $(window).resize(function() {
    setPageHeight();
  });
}

function setPageHeight() {
  height = $('#page').height() - $('#site_header').height() - $('#page_header').height() - 2 - $('#page_notice').height() - $('#page_alert').height() - $('#search_results').height() - 3 - 2 - 2 - $('#taxon_key').height() - 2 - $('#site_footer').height() - 8;
  $("#catalog").height(height);
  $("#catalog .index").height(height - $("#catalog .content").height());
}

