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
  height = $('#page').height() - 240
  $("#page_contents").height(height);
  $("#browser").height(height - 48 - $("#taxon_header").height());
}

