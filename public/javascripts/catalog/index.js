$(function() {
  setupPage();
  $('.reference_key').live('click', expandReferenceKey);
  $('.reference_key_expansion_text').live('click', expandReferenceKey);
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

function expandReferenceKey() {
  $('.reference_key',           $(this).closest('.reference_key_and_expansion')).toggle();
  $('.reference_key_expansion', $(this).closest('.reference_key_and_expansion')).toggle();
}
