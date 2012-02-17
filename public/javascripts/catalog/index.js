$(function() {
  setupPage();
})

function setupPage() {
  setDimensions();
  $(window).resize(function() {
    setDimensions();
  });
}

function setDimensions() {
  setHeight();
  setWidth();
}

function setHeight() {
  height = $('#page').height()
         - $('#site_header').height()
         - $('#page_header').height() - 2
         - $('#page_notice').height()
         - $('#page_alert').height()
         - $('#search_results').height() - 3 - 2 - 2 -
         $('#taxon_key').height() - 2 -
         $('#site_footer').height() - 8;
  $("#catalog").height(height);
  $("#catalog .index").height(height - $("#catalog .content").height());
}

function setWidth() {
  $("#catalog .content").width($('#page').width());
}

function setupHelp() {
  setupQtip('.document_link', "Click to download and view the document");
  setupQtip('.goto_reference_link', "Click to view/edit this reference on its own page");
}
